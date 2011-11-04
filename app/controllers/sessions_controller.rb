class SessionController < ApplicationController
  protect_from_forgery :except => [:create, :destroy, :logout]
    
  # POST /session
  def create
    session[:user_id] = nil
    @login = User.new params[:user]    
    user = User.authenticate @login.email, @login.password
    if user.nil?
      flash[:error] = 'Invalid user/password combination'
    elsif !user.active
      bounce_user("Your account is inactive (did you confirm your #{@login.email} e-mail address?)")
      return
    else
      session[:user_id] = user.id
      @current_user = user
    end
    
    respond_to do |format|
      if session[:user_id]
        format.html { redirect_to root_path }
      else
        format.html do
          @login.reset_password
          render :action => :welcome
        end
      end
    end    
  end
  
  # DELETE /session
  def destroy
    session[:user_id] = nil
    response.headers['X-Account-Management-Status'] = "none"
    flash[:notice] = 'You have been logged out'
    respond_to do |format|
      format.html { redirect_to root_path }
    end    
  end
  
  # GET /session/logout
  # POST /session/logout
  def logout
    destroy
  end
  
  # GET /session
  def index
    if current_user
      @news_flavor = params[:flavor] ? params[:flavor].to_sym : nil
      render :action => :home
    else
      render :action => :welcome
    end
  end
end
