class ProfilesController < ApplicationController
  before_filter :authenticated_as_user,
      :only => [:new, :create, :edit, :show, :update, :websis_lookup]
  before_filter :authenticated_as_admin, :only => [:index, :destroy]

  # GET /profiles
  def index
    @profiles = Profile.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /profiles/1
  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html
    end
  end
  
  # GET /profiles/new
  def new
    user = User.find(params[:user_id])
    @profile = Profile.new :user => user,
                           :athena_username => user.email.split('@')[0]
    new_edit
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
    new_edit
  end
  
  def new_edit
    # Disallow random record updates.
    if !@profile.editable_by_user? @s_user
      notice[:error] = 'That is not yours to play with! Attempt logged.'
      redirect_to root_path
      return
    end

    respond_to do |format|
      format.html { render :action => :new_edit }
      format.js   { render :action => :edit }
    end    
  end
  private :new_edit

  # POST /profiles
  def create
    @profile = Profile.new(params[:profile])
    create_update
  end

  # PUT /profiles/1
  def update
    @profile = Profile.find(params[:id])
    create_update
  end

  def create_update
    # Disallow random record updates.
    if !@profile.editable_by_user? @s_user
      notice[:error] = 'That is not yours to play with! Attempt logged.'
      redirect_to root_path
      return
    end
    
    if @new_record = @profile.new_record?
      success = @profile.save
    else
      params[:profile].delete :user_id  # Profiles should not move among users.
      success = @profile.update_attributes(params[:profile])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Profile successfully #{@profile.new_record? ? 'created' : 'updated'}."
        format.html { redirect_to @profile.user }
        format.js   { render :action => :create_update }
      else
        format.html { render :action => :new_edit }
        format.js   { render :action => :edit }
      end
    end    
  end
  private :create_update
  
  # DELETE /profiles/1
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
    end
  end
  
  # XHR GET /profiles/websis_lookup?athena_id=costan
  def websis_lookup
    @athena_username = params[:athena_id]
    @athena_info = MitStalker.from_user_name @athena_username
    respond_to do |format|
      format.js # websis_lookup.js.rjs
    end
  end
end
