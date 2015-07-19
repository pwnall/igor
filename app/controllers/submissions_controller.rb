class SubmissionsController < ApplicationController
  include CoverSheet

  before_action :authenticated_as_user,
                :only => [:new, :create, :update, :file, :info]
  before_action :authenticated_as_admin,
                :except => [:new, :create, :update, :file, :info]

  # XHR /submissions/xhr_deliverables?assignment_id=1
  def xhr_deliverables
    @assignment = Assignment.where(:id => params[:assignment_id]).
                             includes(:deliverables).first
    unless @assignment
      render :text => ''
      return
    end
    render :layout => false if request.xhr?
  end

  # GET /submissions/request_package
  def request_package
    @assignments = Assignment.by_deadline.includes(:deliverables).all
    @deliverables = @assignments.map(&:deliverables).flatten
  end

  # GET /submissions
  def index
    @assignments = Assignment.by_deadline.includes(:deliverables).
        all.reject { |assignment| assignment.deliverables.empty? }
    @deliverables = @assignments.map(&:deliverables).flatten

    query = Submission.order('updated_at DESC').
        includes(:db_file, :analysis,
                 {:deliverable => :assignment}, :subject)

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

  # GET /submissions/new
  # GET /submissions/new?submission[deliverable_id]=3
  def new
    if params[:submission] and params[:submission][:deliverable_id]
      deliverable = Deliverable.find(params[:submission][:deliverable_id])
      @submission = Submission.where(:deliverable_id => deliverable.id).first
      @submission ||= Submission.new :deliverable => deliverable
    else
      @submission = Submission.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.js   # new.js.rjs
    end
  end

  # POST /submissions
  def create
    deliverable = Deliverable.find params[:submission][:deliverable_id]
    return bounce_user unless deliverable.can_submit? current_user

    @submission = deliverable.submission_for current_user
    @submission ||= Submission.new submission_params
    @submission.subject = current_user

    success = if @submission.new_record?
      @submission.save
    else
      @submission.update_attributes submission_params
    end

    respond_to do |format|
      if success
        @submission.queue_analysis

        flash[:notice] = "Uploaded #{@submission.db_file.f.original_filename} for #{@submission.assignment.name}: #{@submission.deliverable.name}."
        format.html { redirect_to @submission.assignment || root_path }
      else
        flash[:notice] = "Submission for #{@submission.assignment.name}: #{@submission.deliverable.name} failed."
        format.html { redirect_to @submission.assignment || root_path }
      end
    end
  end

  # PUT /submissions/1
  def update
    create
  end

  # POST /submissions/1/reanalyze
  def reanalyze
    @submission = Submission.find params[:id]
    @submission.queue_analysis

    flash[:notice] = "Reanalysis request queued."
    respond_to do |format|
      format.html { redirect_to @submission.analysis }
    end
  end

  # GET /submissions/1/file
  def file
    @submission = Submission.find(params[:id])
    return bounce_user unless @submission.can_read? current_user

    db_file = @submission.full_db_file
    filename = @submission.subject.email.gsub(/[^A-Za-z0-9]/, '_') + '_' +
        db_file.f.original_filename

    # NOTE: The CSP header provides some protection against an attacker who
    #       tries to serve active content (HTML+JS) using the server's origin.
    #       DbFile also explicitly disallows the HTML and XHTML MIME types.
    response.headers['Content-Security-Policy'] = "default-src 'none'"
    send_data db_file.f.file_contents, :filename => filename,
              :type => db_file.f.content_type,
              :disposition => params[:inline] ? 'inline' : 'attachment'
  end

  # GET /submissions/1/info
  def info
    @submission = Submission.find(params[:id])
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
          db_file = s.full_db_file
          extension = db_file.f.original_filename.split('.').last

          zip.put_next_entry "#{prefix}#{basename}#{suffix}.#{extension}"
          zip.write db_file.f.file_contents
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
    params.require(:submission).permit(:deliverable_id, db_file_attributes: [:f])
  end
  private :submission_params

end
