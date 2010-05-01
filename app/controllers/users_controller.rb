class UsersController < ApplicationController
  before_filter :authenticated_as_admin, :except =>
      [:new, :create, :check_name, :edit_password, :update_password,
       :recover_password, :recovery_email]
  before_filter :authenticated_as_user, :only => [:edit_password,
                                                  :update_password]
   
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    token = Token.new(:action => 'confirm_email')
    @user.tokens << token
    # "admin" becomes an administrator by default
    @user.admin = (@user.name == 'admin')

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Please check your e-mail to activate your account.'
        TokenMailer.account_confirmation(token, root_url, 
                                         spend_token_url(token.token)).deliver
        
        format.html { redirect_to(:controller => :sessions, :action => :index) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        @user.reset_password
        
        format.html { render :action => :new }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end    

  # XHR /users/check_name?name=...
  def check_name
    @name = params[:name]
    @user = User.find(:first, :conditions => { :name => @name })
    
    render :layout => false
  end

  # XHR /users/lookup?query=...
  def lookup    
    @query = params[:query]
    @users = User.find_all_by_query!(@query)
    
    respond_to do |format|
      format.js { render :layout => false } # lookup.js.erb
      format.html # nothing so far
      format.xml { render :xml => @users }
    end
  end
  
  # POST /users/set_admin/1?to=true
  def set_admin
    @user = User.find(params[:id])
    @user.admin = params[:to] || false
    @user.save!
    
    flash[:notice] = "#{@user.name} is #{@user.admin ? 'an admin now' : 'no longer an admin'}."
    redirect_to :controller => :users, :action => :index
  end
  
  # GET /users/logout
  # GET /users/logout.xml
  def edit_password
    @user = @s_user
  end
  
  def update_password
    @user = User.find(params[:id])
    return bounce_user('That\'s not yours to play with! Your attempt was logged.') if @user.id != @s_user.id && @s_user.admin == false
    
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Password successfully updated.'
        format.html { redirect_to root_path }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit_password }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /users/recover_password
  def recover_password
    @user = User.new
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
    
    # Generate one-time login token.
    token = @real_user.tokens.create :action => 'login_once'
    
    # send it over via email
    TokenMailer.password_recovery(token, root_url,
                                  spend_token_url(token.token)).deliver

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
      format.xml { head :ok }
    end
  end
end
