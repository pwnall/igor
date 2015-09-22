class SubmissionsController < ApplicationController
  include CoverSheet

  before_action :set_current_course
  before_action :authenticated_as_user,
                only: [:new, :create, :update, :destroy, :file, :info, :promote]
  before_action :authenticated_as_course_editor,
      except: [:new, :create, :update, :destroy, :file, :info, :promote]

  # XHR /6.006/submissions/xhr_deliverables?assignment_id=1
  def xhr_deliverables
    @assignment = current_course.assignments.where(id: params[:assignment_id]).
        includes(:deliverables).first
    unless @assignment
      render :text => ''
      return
    end
    render :layout => false if request.xhr?
  end

  # GET /6.006/submissions/request_package
  def request_package
    @assignments = current_course.assignments.by_deadline.
        includes(:deliverables).all
    @deliverables = @assignments.map(&:deliverables).flatten
  end

  # GET /6.006/submissions
  def index
    @assignments = current_course.assignments.by_deadline.
        includes(:deliverables).all.
        reject { |assignment| assignment.deliverables.empty? }
    @deliverables = @assignments.map(&:deliverables).flatten

    query = Submission.order(updated_at: :desc).includes(
        :db_file, :analysis, {deliverable: :assignment}, :subject)

    if params.has_key? :deliverable_id
      query = query.where(:deliverable_id => params[:deliverable_id])
    end
    if params.has_key? :assignment_id
      assignment_id = params[:assignment_id].to_i
      deliverable_ids = @assignments.find { |a| a.id == assignment_id }.
          deliverables.map(&:id)
      query = query.where(:deliverable_id => deliverable_ids)
    end
    @submissions = query.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # POST /submissions
  def create
    @submission = Submission.new submission_params
    return bounce_user unless @submission.assignment.can_submit? current_user
    @submission.uploader = current_user
    @submission.upload_ip = request.remote_ip
    @submission.copy_collaborators_from_previous_submission

    respond_to do |format|
      if @submission.save
        SubmissionAnalysisJob.perform_later @submission

        format.html do
          redirect_to assignment_url(@submission.assignment,
              course_id: @submission.course), notice: "Uploaded
              #{@submission.file_name} for #{@submission.assignment.name}:
              #{@submission.deliverable.name}."
        end
      else
        format.html do
          redirect_to assignment_url(@submission.assignment,
              course_id: @submission.course), notice: "Submission for
              #{@submission.assignment.name}: #{@submission.deliverable.name}
              failed."
        end
      end
    end
  end

  # DELETE /6.006/submissions/1
  def destroy
    submission = Submission.find params[:id]
    return bounce_user unless submission.can_delete? current_user
    submission.destroy

    respond_to do |format|
      format.html do
        redirect_to assignment_url(submission.assignment,
            course_id: submission.course), notice: "Submission for
            #{submission.assignment.name}: #{submission.deliverable.name}
            removed."
      end
    end
  end

  # POST /submissions/1/reanalyze
  def reanalyze
    @submission = Submission.find params[:id]
    SubmissionAnalysisJob.perform_later @submission

    respond_to do |format|
      format.html do
        redirect_to analysis_url(@submission.analysis,
            course_id: @submission.course), notice: 'Reanalysis request queued.'
      end
    end
  end

  # POST /6.006/submissions/1/promote
  def promote
    submission = Submission.find params[:id]
    return bounce_user unless submission.can_edit? current_user
    submission.touch

    respond_to do |format|
      format.html do
        redirect_to assignment_url(submission.assignment,
            course_id: submission.course), notice: "The submission that will
            determine your grade for #{submission.assignment.name}:
            #{submission.deliverable.name} has changed."
      end
    end
  end

  # GET /submissions/1/file
  def file
    @submission = Submission.find(params[:id])
    return bounce_user unless @submission.can_read? current_user

    db_file = @submission.db_file
    filename = @submission.subject.email.gsub(/[^A-Za-z0-9]/, '_') + '_' +
        @submission.file_name

    # NOTE: The CSP header provides some protection against an attacker who
    #       tries to serve active content (HTML+JS) using the server's origin.
    #       DbFile also explicitly disallows the HTML and XHTML MIME types.
    response.headers['Content-Security-Policy'] = "default-src 'none'"
    send_data @submission.contents, :filename => filename,
              :type => db_file.f.content_type,
              :disposition => params[:inline] ? 'inline' : 'attachment'
  end

  # XHR GET /6.006/submissions/1/info
  def info
    @submission = Submission.find params[:id]
    return bounce_user unless @submission.can_read? current_user
    render :layout => false if request.xhr?
  end

  # GET /submissions/package_assignment
  def package_assignment
    @assignment = Assignment.find(params[:assignment_id])

    deliverable_ids = params[:package_include].select { |k, v| v == '1' }.keys
    @deliverables = Deliverable.where(:id => deliverable_ids).
                                includes(:assignment)

    if @deliverables.empty?
      # Admin only requested cover sheets, so find all users that submitted
      # anything for this assignment.
      deliverable_ids = @assignment.deliverables.map(&:id)
    end

    seed_submissions = Submission.where(:deliverable_id => deliverable_ids)
    unless params[:use_cutoff].blank?
      cutoff = Time.local(*([:year, :month, :day, :hour, :minute].
                          map { |e| params[:cutoff][e].to_i }))
      seed_submissions = seed_submissions.where(
          Submission.arel_table[:updated_at].gteq(cutoff))
    end

    @subjects = seed_submissions.map(&:subject).uniq
    subject_ids = @subjects.map(&:id)
    @submissions = Submission.where(deliverable_id: deliverable_ids,
                                    subject_id: subject_ids).
                              includes(:deliverable, :subject).order(:id)

    if @submissions.empty?
      flash[:alert] = 'There is no submission meeting your conditions.'
      request_package
      render :action => :request_package
      return
    end

    zip_buffer = Zip::OutputStream.write_buffer do |zip|
      # write out submissions
      unless @deliverables.empty?
        @submissions.each do |s|
          prefix = params[:filename_prefix][s.deliverable.id.to_s] || ''
          suffix = params[:filename_suffix][s.deliverable.id.to_s] || ''
          subject = s.subject
          basename = subject.respond_to?(:email) ?
              subject.email.split('@').first :
              subject.name.underscore.gsub(' ', '_')
          extension = s.file_name.split('.').last

          zip.put_next_entry "#{prefix}#{basename}#{suffix}.#{extension}"
          zip.write s.contents
        end
      end

      # generate cover sheets
      if params[:package_include]['cover'] == '1'
        @subjects.each do |subject|
          prefix = params[:filename_prefix]['cover'] || ''
          suffix = params[:filename_suffix]['cover'] || ''
          basename = subject.respond_to?(:email) ?
              subject.email.split('@').first :
              subject.name.underscore.gsub(' ', '_')
          extension = 'pdf'

          pdf_contents = cover_sheet_for_assignment subject, @assignment

          zip.put_next_entry "#{prefix}#{basename}#{suffix}.#{extension}"
          zip.write pdf_contents
        end
      end
    end

    # NOTE: We don't really need a CSP here, because we're serving a zip
    #       file. We're adding it in to make sure no terrible incident
    #       happens where a misconfigured nginx unpacks the archive  and
    #       serves some file inside that happens to look like HTML to the
    #       MIME type sniffer in the browser.
    response.headers['Content-Security-Policy'] = "default-src 'none'"
    send_data zip_buffer.string, type: 'application/zip',
        disposition: 'download', filename: "assignment_#{@assignment.id}.zip"
  end

  def with_temp_dir
    temp_dir = 'tmp/' + (0...16).map { rand(256).to_s(16) }.join
    Dir.mkdir temp_dir
    yield temp_dir
    FileUtils.rm_r temp_dir
    temp_dir
  end
  private :with_temp_dir

  # Permit updating and creating submissions.
  def submission_params
    params.require(:submission).permit(:deliverable_id,
        db_file_attributes: [:f])
  end
  private :submission_params

end
