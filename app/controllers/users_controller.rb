class UsersController < ApplicationController
  before_filter :authenticated_as_admin, :except =>
      [:new, :create, :show, :check_email, :edit_password, :update_password,
       :reset_password, :recovery_email]
  
  before_filter :authenticated_as_user, :only => [:edit_password,
                                                  :update_password, :show]
   
  # GET /users
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # GET /users/new
  def new
    @user = User.new
    @user.build_profile
    @user.registrations.build :course => Course.main
    @user.registrations.first.build_prerequisite_answers

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    @user = User.new(params[:user])
    # The first user becomes an administrator by default.
    @user.admin = (User.count == 0)

    respond_to do |format|
      if @user.save
        flash[:error] = 'Please check your e-mail to activate your account.'
        token = @user.tokens.create :action => 'confirm_email'
        TokenMailer.account_confirmation(token, root_url, 
            spend_token_url(:token => token.token)).deliver
        
        format.html { redirect_to session_url }
      else
        format.html { render :action => :new }
      end
    end
  end
  
  # PUT /users/1
  def update
    # TODO(costan): figure out the usefulness of this, maybe drop it
    
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
      else
        format.html { render :action => :edit }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end    

  # XHR /users/check_email?email=...
  def check_email
    @email = params[:user][:email]
    @user = User.with_email @email
    
    render :layout => false
  end

  # XHR /users/lookup?query=...
  def lookup    
    @query = params[:query]
    @users = User.find_all_by_query!(@query)
    
    respond_to do |format|
      format.js { render :layout => false } # lookup.js.erb
      format.html # nothing so far
    end
  end
  
  # POST /users/set_admin/1?to=true
  def set_admin
    @user = User.find(params[:id])
    @user.admin = params[:to] || false
    @user.save!
    
    flash[:notice] = "#{@user.email} is #{@user.admin ? 'an admin now' : 'no longer an admin'}."
    redirect_to :controller => :users, :action => :index
  end
    
  # POST /users/recovery_email
  def recovery_email
    @user = User.new params[:user]
    
    template = User.where(:email => params[:user][:email])
    
    # First, try to find an active user matching the e-mail.
    @real_user = template.where(:active => true).first
    unless @real_user
      # If there's none, get the first user trying to register.
      @real_user = template.first
    end
    
    unless @real_user
      flash[:notice] = "No account for e-mail #{params[:user][:email]}. Are you sure you registered?"
      render :action => :recover_password
      return
    end
    
    # Generate one-time login token and e-mail it.
    token = @real_user.tokens.create :action => 'login_once'
    TokenMailer.password_recovery(token, root_url,
        spend_token_url(:token => token.token)).deliver

    # go home
    flash[:notice] = "Please check your e-mail at #{params[:user][:email]} for next steps."
    redirect_to root_path
  end
  
  def impersonate
    @user = User.find(params[:id])
    return bounce_user('Cannot impersonate another admin.') if @user.admin?
    
    session[:user_id] = @user.id
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
end
