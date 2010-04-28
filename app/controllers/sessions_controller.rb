class SessionsController < ApplicationController
  protect_from_forgery :except => [:create, :destroy, :logout]
  
  # GET /sessions/new
  def new
    if @s_user
      redirect_to root_path
    else
      @login = User.new
    end
  end
  
  # POST /sessions
  # POST /sessions.xml
  def create
    session[:user_id] = nil
    @login = User.new params[:user]    
    @s_user = User.authenticate @login.name, @login.password
    if @s_user.nil?
      flash[:error] = 'Invalid user/password combination'
    elsif !@s_user.active
      flash[:error] = "Your account is not active (did you confirm your #{@login.email} e-mail address?)"
    else
      session[:user_id] = @s_user.id
    end
    
    respond_to do |format|
      if session[:user_id]
        format.html { redirect_to root_path }
        format.xml { head :ok }
      else
        format.html { @login.reset_password; render :action => :new }
        format.xml  { render :xml => nil, :status => :unprocessable_entity }
      end
    end    
  end
  
  # DELETE /sessions
  # DELETE /sessions.xml
  def destroy
    session[:user_id] = nil
    response.headers['X-Account-Management-Status'] = "none"
    flash[:notice] = 'You have been logged out'
    respond_to do |format|
      format.html { redirect_to root_path }
      format.xml  { head :ok }
    end    
  end
  
  # GET /sessions/logout
  # POST /sessions/logout
  def logout
    destroy
  end
  
  # GET /sessions/1
  def show
    # This is for Firefox Account Manager.
    render :text => ''
  end
  
  # GET /sessions
  before_filter :authenticated_as_user, :only => [:index]
  def index
  end
end
