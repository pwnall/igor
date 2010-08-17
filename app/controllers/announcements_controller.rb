class AnnouncementsController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:show]
  before_filter :authenticated_as_user, :only => [:show]
  
  # GET /announcements
  # GET /announcements.xml
  def index
    @announcements = Announcement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @announcements }
    end
  end

  # GET /announcements/1
  # GET /announcements/1.xml
  def show
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/new
  # GET /announcements/new.xml
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
      format.xml  { render :xml => @announcement }
    end
  end
  private :new_edit

  # POST /announcements
  # POST /announcements.xml
  def create
    params[:announcement][:author_id] = @s_user.id
    @announcement = Announcement.new(params[:announcement])
    create_update
  end

  # PUT /announcements/1
  # PUT /announcements/1.xml
  def update
    params[:announcement][:author_id] = @s_user.id
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
        format.xml do
          if is_new_record
            render :xml => @announcement, :status => :created, :location => @announcement
          else
            head :ok
          end
        end  
      else
        format.html { render :action => :new_edit }
        format.js   { render :action => :new_edit }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.xml
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.xml  { head :ok }
    end
  end
end