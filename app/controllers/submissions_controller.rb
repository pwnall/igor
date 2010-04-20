class SubmissionsController < ApplicationController
  include CoverSheet
  
  before_filter :authenticated_as_user, :only => [:create, :update, :file]
  before_filter :authenticated_as_admin, :except => [:create, :update, :file]
  
  # XHR /submissions/xhr_update_deliverables/0?assignment_id=1
  def xhr_update_deliverables
    @assignment = Assignment.find(:first, :conditions => {:id => params[:assignment_id]}, :include => :deliverables)
    respond_to do |format|
      format.js do
        return if @assignment # xhr_update_deliverables.html.erb
        render :text => ''
      end
    end
  end

  # XHR /submissions/xhr_update_deliverables/0?assignment_id=1
  def xhr_update_cutoff
    @assignment = Assignment.find(:first, :conditions => {:id => params[:assignment_id]}, :include => :deliverables)
    respond_to do |format|
      format.js
    end
  end  
  
  # GET /submissions/request_package
  def request_package
    @deliverables = Deliverable.find :all, :order => 'deliverables.id DESC',
                                     :include => :assignment
    @assignments = Assignment.find :all, :order => 'assignments.id DESC'
  end
  
  # GET /submissions
  # GET /submissions.xml
  def index
    @deliverables = Deliverable.find(:all, :order => 'deliverables.id DESC', :include => :assignment)
    @assignments = Assignment.find(:all, :order => 'assignments.id DESC')
    
    submissions_conditions = {}
    submissions_conditions[:deliverable_id] = params[:deliverable_id] if params.has_key? :deliverable_id
    if params.has_key? :assignment_id
      assignment_id = params[:assignment_id].to_i      
      submissions_conditions[:deliverable_id] = @assignments.find { |a| a.id == assignment_id }.deliverables.map { |a| a.id }
    end
    @submissions = Submission.find(:all, :conditions => submissions_conditions, :order => 'submissions.updated_at DESC', :include => [{:deliverable => :assignment, :user => :profile}, :run_result])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @submissions }
    end
  end

  # POST /submissions
  # POST /submissions.xml
  def create    
    @submission = Submission.find(:first, :conditions => {:user_id => @s_user.id, :deliverable_id => params[:submission][:deliverable_id]})
    @submission ||= Submission.new(params[:submission])
    @submission.user = @s_user
    
    create_update
  end
  
  # POST /submissions/revalidate/1
  def revalidate
    @submission = Submission.find(params[:id])
    @submission.run_result ||= RunResult.new(:submission => @submission)
    unless @submission.run_result.new_record?
      # reset the run result fields
      [:stdout=, :stderr=, :score=, :diagnostic=].each { |msg| @submission.run_result.send msg, nil }
    end
    @submission.run_result.diagnostic = 'queued'
    @submission.run_result.save!

    OfflineTasks.validate_submission(@submission)
    flash[:notice] = "Re-validating #{@submission.code.original_filename} from #{@submission.deliverable.assignment.name}: #{@submission.deliverable.name}. "
    respond_to do |format|
      format.html { redirect_to submissions_path }
      format.xml { head :ok }
    end    
  end
  
  def create_update
    @new_record = @submission.new_record?
    @submission.run_result ||= RunResult.new(:submission => @submission)
    unless @submission.run_result.new_record?
      # reset the run result fields
      [:stdout=, :stderr=, :score=, :diagnostic=].each { |msg| @submission.run_result.send msg, nil }
    end
    @submission.run_result.diagnostic = 'queued'
    @success = @new_record ? @submission.save : @submission.update_attributes(params[:submission])
    
    respond_to do |format|
      if @success
        @submission.run_result.save!
        OfflineTasks.validate_submission @submission        
        
        flash[:notice] = "Uploaded #{@submission.code.original_filename} for #{@submission.deliverable.assignment.name}: #{@submission.deliverable.name}. Don't forget to <a href=\"#{url_for :controller => :assignment_feedbacks, :action => :new, :assignment_id => @submission.deliverable.assignment.id}\">submit feedback</a>!"
        format.html { redirect_to root_path }
        format.xml do
          if is_new_record
            render :xml => @submission, :status => :created, :location => @submission
          else
            head :ok
          end  
        end  
      else
        if @submission.deliverable.nil?
          flash[:notice] = "Submission did not contain a deliverable selection."
        else
          flash[:notice] = "Submission for #{@submission.deliverable.assignment.name}: #{@submission.deliverable.name} failed."
        end
        format.html { redirect_to root_path }
        format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  # GET /submissions/1/file
  def file
    @submission = Submission.find(params[:id])
    if @s_user.id != @submission.user_id && !@s_user.admin?
      bounce_user "That's not yours to play with. Your attempt has been logged."
      return
    end
    
    filename = @submission.user.name + '_' + @submission.code.original_filename
    send_data @submission.code.file_contents, :filename => filename,
              :type => @submission.code.content_type,
              :disposition => params[:inline] ? 'inline' : 'attachment'
  end

  # GET /submissions/package_assignment
  def package_assignment
    @assignment = Assignment.find(params[:assignment_id])
    
    deliverable_ids = params[:package_include].select { |k, v| v == '1' }.
                                               map(&:first)
    @deliverables = Deliverable.where(:id => deliverable_ids).
                                includes(:assignment)
    
    if @deliverables.empty?
      # Admin only requested cover sheets, so find all users that submitted
      # anything for this assignment.
      deliverable_ids = @assignment.deliverables.map(&:id)
    end

    seed_submissions = Submission.where :deliverable_id => deliverable_ids
    unless params[:cutoff_enable].blank?
      cutoff = Time.local(*([:year, :month, :day, :hour, :minute].
                          map { |e| params[:cutoff][e].to_i }))
      seed_submissions = seed_submissions.          
          where(Submission.arel_table[:updated_at].gteq(cutoff))
    end
    
    user_ids = seed_submissions.map(&:user_id).uniq
    if team_partition = @assignment.team_partition
      user_ids = User.where(:id => user_ids).map { |u|
        team_partition.team_for_user(u) }.reject(&:nil?).
                       map { |team| team.memberships.map(&:user_id) }.
                       flatten.uniq
    end
    @users = User.where :id => user_ids
    @user_submissions = Submission.where(:deliverable_id => deliverable_ids,
                                         :user_id => user_ids).
                                   includes(:deliverable, :user).
                                   order(:id)
    
    if @user_submissions.empty?
      flash[:error] = 'There is no submission meeting your conditions.'
      request_package
      render :action => :request_package
      return
    end
    
    if team_partition
      @teams = @users.map { |u| team_partition.team_for_user(u) }.uniq
    else
      @teams = nil
    end
    
    temp_dir = with_temp_dir do |tempdir|
      # write out submissions
      unless @deliverables.empty?
        @user_submissions.each do |s|
          prefix = params[:filename_prefix][s.deliverable.id.to_s] || ''
          suffix = params[:filename_suffix][s.deliverable.id.to_s] || ''
          basename = if team_partition
            team_partition.team_for_user(s.user).name.underscore.gsub(' ', '_')
          else
            s.user.email.split('@').first
          end
          extension = s.code.original_filename.split('.').last
          fname = "#{tempdir}/#{prefix}#{basename}#{suffix}.#{extension}"
          File.open(fname, 'w') { |f| f.write s.code.file_contents }      
        end
      end
      
      # generate cover sheets
      if params[:package_include]['cover'] == '1'
        (@teams || @users).each do |target|
          prefix = params[:filename_prefix]['cover'] || ''
          suffix = params[:filename_suffix]['cover'] || ''
          basename = team_partition ? target.name.underscore.gsub(' ', '_') :
                                      target.email.split('@').first          
          extension = 'pdf'
          fname = "#{tempdir}/#{prefix}#{basename}#{suffix}.#{extension}"
          cover_sheet_for_assignment target, @assignment, fname
        end        
      end
      
      # zip up the submissions
      cur_dir = Dir.pwd
      Dir.chdir(tempdir) { Kernel.system "zip #{cur_dir}/#{tempdir}.zip *" }
      package_fname = case @deliverables.length
      when 0
        "cover_sheets_#{@assignment.id}.zip"
      when 1
        d = @deliverables.first
        d.filename[0...(d.filename.rindex(?.) || d.filename.length)] + '.zip'
      else
        "assignment_#{@assignment.id}.zip"
      end      
      send_data File.open("#{tempdir}.zip", 'r') { |f| f.read }, :filename => package_fname, :disposition => 'inline'      
    end
    File.delete "#{temp_dir}.zip"    
  end
  
  private
  def with_temp_dir
    tempdir = 'tmp/' + (0...16).map { rand(256).to_s(16) }.join
    Dir.mkdir tempdir
    yield tempdir
    FileUtils.rm_r tempdir
  end
end
