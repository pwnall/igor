class SessionsController < ApplicationController
  # GET /sessions/new
  def new
    if @s_user
      redirect_to root_path
    else
      @user = User.new
    end
  end
  
  # POST /sessions
  # POST /sessions.xml
  def create
    session[:user_id] = nil
    @user = User.new params[:user]    
    @s_user = User.authenticate @user.name, @user.password
    if @s_user.nil?
      flash[:error] = 'Invalid user/password combination'
    elsif !@s_user.active
      flash[:error] = "Your account is not active (did you confirm your #{@user.email} e-mail address?)"
    else
      session[:user_id] = @s_user.id
    end
    
    respond_to do |format|
      if session[:user_id]
        format.html { redirect_to root_path }
        format.xml { head :ok }
      else
        format.html { @user.reset_password; render :action => :new }
        format.xml  { render :xml => nil, :status => :unprocessable_entity }
      end
    end    
  end
  
  # DELETE /sessions
  # DELETE /sessions.xml
  def destroy
    session[:user_id] = nil
    flash[:notice] = 'You have been logged out'
    respond_to do |format|
      format.html { redirect_to root_path }
      format.xml  { head :ok }
    end    
  end
  
  # GET /sessions
  before_filter :authenticated_as_user, :only => [:index]
  def index
    @profile = @s_user.profile
    @student_info = @s_user.student_info
    
    @feedbacks = AssignmentFeedback.all :conditions =>
         { :user_id => @s_user.id }
    feedbacks_by_aid = @feedbacks.index_by &:assignment_id
    
    @submissions = Submission.all :conditions => { :user_id => @s_user.id },
                                  :order => 'updated_at DESC'
    submissions_by_aid = @submissions.index_by { |s| s.assignment.id }
    
    @assignments = Assignment.all :conditions => { :accepts_feedback => true }
    @assignments_wo_feedback = @assignments.select do |assignment|
      # Assignments where the user didn't submit feedback yet, and either
      # (1) the user submitted a deliverable or (2) the assignment is team-based
      assignment.accepts_feedback && !feedbacks_by_aid[assignment.id] &&
          (submissions_by_aid[assignment.id] || assignment.team_partition)
    end
    
    @notice_statuses = @s_user.notice_statuses.all
    @notice_statuses.each &:mark_seen!
    @notice_statuses.sort! { |a, b| b.notice.created_at <=> a.notice.created_at }
  end
end
