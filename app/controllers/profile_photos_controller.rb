class ProfilePhotosController < ApplicationController
  before_filter :authenticated_as_user,
      :only => [:new, :create, :edit, :show, :update, :profile]
  before_filter :authenticated_as_admin, :only => [:index, :destroy]
  
  # GET /profile_photos
  def index
    @profile_photos = ProfilePhoto.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /profile_photos/1
  def show
    @profile_photo = ProfilePhoto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /profile_photos/new
  def new
    @profile_photo =
        ProfilePhoto.where(:profile_id => params[:profile_id]).first ||
        ProfilePhoto.new(:profile_id => params[:profile_id])
    
    unless @profile_photo.profile.editable_by_user?(@s_user)
      notice[:error] = 'That is not yours to play with! Attempt logged.'
      redirect_to root_url
      return      
    end
    
    respond_to do |format|
      format.html { render :action => :edit }
      format.js   { render :action => :edit }
    end
  end

  # POST /profile_photos
  def create
    @profile_photo =
        ProfilePhoto.where(:profile_id => params[:profile_photo][:profile_id]).
                     first
    @profile_photo ||= ProfilePhoto.new params[:profile_photo]
    create_update
  end
  
  # PUT /profile_photos/1
  def update
    @profile_photo = ProfilePhoto.find params[:id]
    create_update
  end
  
  def create_update
    unless @profile_photo.profile.editable_by_user?(@s_user)
      notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
      redirect_to root_url
      return      
    end
    
    if @profile_photo.new_record?
      success = @profile_photo.save
    else
      success = @profile_photo.update_attributes(params[:profile_photo])
    end

    respond_to do |format|
      if success 
        format.html { redirect_to(@profile_photo.profile.user, :notice => 'Profile photo was successfully changed.') }
      else
        format.html { render :action => :new }
      end
    end    
  end
  private :create_update
  
  # GET /profile_photos/1/thumb
  def thumb
    @profile_photo = ProfilePhoto.find params[:id]
    send_data @profile_photo.pic_thumb_file, :filename => 'thumb.png',
              :type => 'image/png'
  end
  
  # GET /profile_photos/1/profile
  def profile
    @profile_photo = ProfilePhoto.find params[:id]
    send_data @profile_photo.pic_profile_file, :filename => 'profile.png',
              :type => 'image/png'    
  end

  # DELETE /profile_photos/1
  def destroy
    @profile_photo = ProfilePhoto.find(params[:id])
    @profile_photo.destroy

    respond_to do |format|
      format.html { redirect_to @profile_photo.profile.user }
    end
  end
end
