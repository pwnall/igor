class SessionsController < ApplicationController
  protect_from_forgery :except => [:create, :destroy, :logout]
    
  # POST /sessions
  def create
    session[:user_id] = nil
    @login = User.new params[:user]    
    user = User.authenticate @login.email, @login.password
    if user.nil?
      flash[:error] = 'Invalid user/password combination'
    elsif !user.active
      flash[:error] = "Your account is not active (did you confirm your #{@login.email} e-mail address?)"
    else
      session[:user_id] = user.id
      @s_user = user
    end
    
    respond_to do |format|
      if session[:user_id]
        format.html { redirect_to root_path }
      else
        format.html { @login.reset_password; render :action => :index }
      end
    end    
  end
  
  # DELETE /sessions
  def destroy
    session[:user_id] = nil
    response.headers['X-Account-Management-Status'] = "none"
    flash[:notice] = 'You have been logged out'
    respond_to do |format|
      format.html { redirect_to root_path }
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
  def index
    @news_flavor = params[:flavor] ? params[:flavor].to_sym : nil
  end
end
