class UsersController < ApplicationController
  before_filter :authenticated_as_admin, :except =>
      [:new, :create, :show, :check_email, :edit_password, :update_password]
  
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
        token = Tokens::EmailVerification.random_for @user.email_credential
        SessionMailer.email_verification_email(token, request.host_with_port).
                      deliver
        
        format.html do
          redirect_to new_session_url,
              :error => 'Please check your e-mail to verify your account.'
        end
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
    
  def impersonate
    @user = User.find(params[:id])
    return bounce_user('Cannot impersonate another admin.') if @user.admin?
    
    session[:user_id] = @user.id
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
end
