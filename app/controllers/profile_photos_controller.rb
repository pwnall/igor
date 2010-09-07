class ProfilePhotosController < ApplicationController
  before_filter :authenticated_as_user,
      :only => [:new, :create, :edit, :show, :update, :profile]
  before_filter :authenticated_as_admin, :only => [:index, :destroy]
  
  # GET /profile_photos
  # GET /profile_photos.xml
  def index
    @profile_photos = ProfilePhoto.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile_photos }
    end
  end

  # GET /profile_photos/1
  # GET /profile_photos/1.xml
  def show
    @profile_photo = ProfilePhoto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile_photo }
    end
  end

  # GET /profile_photos/new
  # GET /profile_photos/new.xml
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
      format.xml  { render :xml => @profile_photo }
    end
  end

  # POST /profile_photos
  # POST /profile_photos.xml
  def create
    @profile_photo =
        ProfilePhoto.where(:profile_id => params[:profile_photo][:profile_id]).
                     first
    @profile_photo ||= ProfilePhoto.new params[:profile_photo]
    create_update
  end
  
  # PUT /profile_photos/1
  # PUT /profile_photos/1.xml
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
      success = @profile_photo.save!
    else
      success = @profile_photo.update_attributes(params[:profile_photo])
    end

    respond_to do |format|
      if success 
        format.html { redirect_to(@profile_photo.profile.user, :notice => 'Profile photo was successfully changed.') }
        format.xml  { render :xml => @profile_photo, :status => :created, :location => @profile_photo }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @profile_photo.errors, :status => :unprocessable_entity }
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
  # DELETE /profile_photos/1.xml
  def destroy
    @profile_photo = ProfilePhoto.find(params[:id])
    @profile_photo.destroy

    respond_to do |format|
      format.html { redirect_to @profile_photo.profile.user }
      format.xml  { head :ok }
    end
  end
end
