class ProfilePhotosController < ApplicationController
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
    @profile_photo = ProfilePhoto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile_photo }
    end
  end

  # GET /profile_photos/1/edit
  def edit
    @profile_photo = ProfilePhoto.find(params[:id])
  end

  # POST /profile_photos
  # POST /profile_photos.xml
  def create
    @profile_photo = ProfilePhoto.new(params[:profile_photo])

    respond_to do |format|
      if @profile_photo.save
        format.html { redirect_to(@profile_photo, :notice => 'Profile photo was successfully created.') }
        format.xml  { render :xml => @profile_photo, :status => :created, :location => @profile_photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile_photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profile_photos/1
  # PUT /profile_photos/1.xml
  def update
    @profile_photo = ProfilePhoto.find(params[:id])

    respond_to do |format|
      if @profile_photo.update_attributes(params[:profile_photo])
        format.html { redirect_to(@profile_photo, :notice => 'Profile photo was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile_photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_photos/1
  # DELETE /profile_photos/1.xml
  def destroy
    @profile_photo = ProfilePhoto.find(params[:id])
    @profile_photo.destroy

    respond_to do |format|
      format.html { redirect_to(profile_photos_url) }
      format.xml  { head :ok }
    end
  end
end
