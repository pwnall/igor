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
    
    @submissions = Submission.find(:all, :conditions => {:user_id => @s_user.id}, :order => 'updated_at DESC')
    @assignments_h = Hash[*(@submissions.map { |s| [s.deliverable.assignment.id, s.deliverable.assignment] }.flatten)]
    @feedbacks = AssignmentFeedback.find(:all, :conditions => {:user_id => @s_user.id, :assignment_id => @assignments_h.keys })
    @feedbacks_h = Hash[*(@feedbacks.map { |f| [f.assignment_id, f] }.flatten)]
    
    @notice_statuses = @s_user.notice_statuses
    @notice_statuses.each { |status| status.mark_seen! }
    @notice_statuses.sort! { |a, b| b.notice.created_at <=> a.notice.created_at }
  end
end
