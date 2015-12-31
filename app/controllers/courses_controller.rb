class CoursesController < ApplicationController
  before_action :authenticated_as_admin, except: [:connect, :edit, :update]
  before_action :authenticated_as_user, only: [:connect, :edit, :update]
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /_/courses/connect
  def connect
    courses = Course.all

    @new_courses = courses - current_user.registered_courses -
        current_user.employed_courses
  end

  # GET /_/courses
  def index
    @courses = Course.all
  end

  # GET /6.006/course
  def show
  end

  # GET /_/courses/new
  def new
    @course = Course.new
  end

  # GET /6.006/edit
  def edit
  end

  # POST /_/courses
  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to courses_url, notice: "Course #{@course.number} created."
    else
      render :new
    end
  end

  # PATCH /6.006/course
  def update
    if @course.update(course_params)
      if current_user.admin?
        target_url = courses_url
      else
        target_url = course_root_url course_id: @course
      end
      redirect_to target_url,
                  notice: "Course #{@course.number} settings updated."
    else
      render :edit
    end
  end

  # DELETE /6.006/course
  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find_by! number: params[:id]
      bounce_user unless @course.can_edit? current_user
      @current_course = @course
    end

    # Only allow a trusted parameter "white list" through.
    def course_params
      params.require(:course).permit :number, :title, :email, :ga_account,
          :heap_appid, :email_on_role_requests,
          :has_recitations, :has_surveys, :has_teams, :section_size
    end
end
