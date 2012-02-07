class SubmissionsController < ApplicationController
  include CoverSheet
  
  before_filter :authenticated_as_user, :only => [:new, :create, :update, :file]
  before_filter :authenticated_as_admin, :except => [:new, :create, :update, :file]
  
  # XHR /submissions/xhr_update_deliverables?assignment_id=1
  def xhr_update_deliverables
    @assignment = Assignment.where(:id => params[:assignment_id]).
                             includes(:deliverables).first
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
    @assignments = Assignment.order('deadline DESC').includes(:deliverables).all
    @deliverables = @assignments.map(&:deliverables).flatten
  end
  
  # GET /submissions
  def index
    @assignments = Assignment.order('deadline DESC').includes(:deliverables).
        all.reject { |assignment| assignment.deliverables.empty? }
    @deliverables = @assignments.map(&:deliverables).flatten
    
    query = Submission.order('updated_at DESC').
        includes(:db_file, :analysis,
                 {:deliverable => :assignment, :user => :profile})
    
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
    @submission = deliverable.submission_for current_user
    @submission ||= Submission.new params[:submission]
    @submission.user = current_user
    
    success = if @submission.new_record?
      @submission.save
    else
      @submission.update_attributes(params[:submission])
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
  
  # POST /submissions/revalidate/1
  def revalidate
    @submission = Submission.find(params[:id])
    @submission.queue_analysis
    
    flash[:notice] = "Reanalyzing #{@submission.db_file.f.original_filename} from #{@submission.deliverable.assignment.name}: #{@submission.deliverable.name}. "
    respond_to do |format|
      format.html { redirect_to submissions_path }
    end    
  end
  
  # GET /submissions/1/file
  def file
    @submission = Submission.find(params[:id])
    if current_user.id != @submission.user_id && !current_user.admin?
      
      
    end
    
    db_file = @submission.full_db_file
    filename = @submission.user.email.gsub(/[^A-Za-z0-9]/, '_') + '_' +
        db_file.f.original_filename
    send_data db_file.f.file_contents, :filename => filename,
              :type => db_file.f.content_type,
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
          db_file = s.full_db_file
          extension = db_file.f.original_filename.split('.').last
          fname = "#{tempdir}/#{prefix}#{basename}#{suffix}.#{extension}"
          File.open(fname, 'w') { |f| f.write db_file.f.file_contents }
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
