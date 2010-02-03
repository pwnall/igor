class SessionsController < ApplicationController
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
        format.html { redirect_to :controller => :welcome, :action => :home }
        format.xml { head :ok }
      else
        format.html { @user.reset_password; render :action => :index }
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
      format.html { redirect_to :action => :index }
      format.xml  { head :ok }
    end    
  end
  
  # GET /sessions
  def index
    if @s_user
      redirect_to(:controller => :welcome, :action => :home)
      return
    end

    @user = User.new
 end
end
