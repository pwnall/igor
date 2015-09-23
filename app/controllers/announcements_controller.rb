class AnnouncementsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_admin, :except => [:show]
  before_action :authenticated_as_user, :only => [:show]

  # GET /announcements
  def index
    @announcements = current_course.announcements

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /announcements/new
  def new
    @announcement = Announcement.new course: current_course
  end

  # GET /announcements/1/edit
  def edit
    @announcement = current_course.announcements.find params[:id]
  end

  # POST /announcements
  def create
    @announcement = Announcement.new announcement_params
    @announcement.author = current_user
    @announcement.course = current_course

    respond_to do |format|
      if @announcement.save
        format.html do
          redirect_to root_url(course_id: @announcement.course),
              notice: 'Announcement successfully saved.'
        end
      else
        format.html do
          render :edit
        end
      end
    end
  end

  # PUT /announcements/1
  def update
    @announcement = current_course.announcements.find params[:id]

    respond_to do |format|
      if @announcement.update announcement_params
        format.html do
          redirect_to root_url(course_id: @announcement.course),
              notice: 'Announcement successfully updated.'
        end
      else
        format.html do
          render :edit
        end
      end
    end
  end

  # DELETE /announcements/1
  def destroy
    @announcement = current_course.announcements.find params[:id]
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  # Permits creating and updating announcements.
  def announcement_params
    params.require(:announcement).permit :open_to_visitors, :headline, :contents
  end
  private :announcement_params
end
