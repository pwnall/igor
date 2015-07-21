class AnnouncementsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_admin, :except => [:show]
  before_action :authenticated_as_user, :only => [:show]

  # GET /announcements
  def index
    @announcements = Announcement.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /announcements/1
  def show
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /announcements/new
  def new
    @announcement = Announcement.new
    new_edit
  end

  # GET /announcements/1/edit
  def edit
    @announcement = Announcement.find(params[:id])
    new_edit
  end

  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.js   { render :action => :new_edit }
    end
  end
  private :new_edit

  # POST /announcements
  def create
    params[:announcement][:author_id] = current_user.id
    @announcement = Announcement.new(params[:announcement])
    create_update
  end

  # PUT /announcements/1
  def update
    params[:announcement][:author_id] = current_user.id
    @announcement = Announcement.find(params[:id])
    create_update
  end

  def create_update
    is_new_record = @announcement.new_record?
    if is_new_record
      success = @announcement.save
    else
      success = @announcement.update_attributes(params[:announcement])
    end

    respond_to do |format|
      if success
        flash[:announcement] = "Site-wide announcement successfully #{is_new_record ? 'published' : 'updated'}."
        format.html { redirect_to root_path }
        format.js   { render :action => :create_update }
      else
        format.html { render :action => :new_edit }
        format.js   { render :action => :new_edit }
      end
    end
  end

  # DELETE /announcements/1
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  # Permits creating and updating announcements.
  def announcement_params
    params.require(:announcement).permit :subject_id, :subject_type, :metric_id, :score
  end
  private :announcement_params

end
