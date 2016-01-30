class AssignmentsController < ApplicationController
  include SidebarLayout

  before_action :set_current_course
  before_action :authenticated_as_course_editor, except: [:index, :show]
  before_action :authenticated_as_user, only: [:index, :show]
  before_action :set_assignment, only: [:show, :edit, :update, :destroy,
      :schedule, :deschedule, :release, :unrelease, :release_grades]

  # GET /6.006/assignments
  # GET /6.006/assignments.json
  def index
    @assignments = current_course.assignments_for current_user

    respond_to do |format|
      format.html  # index.html.erb
      format.json  # index.json.jbuilder
    end
  end

  # GET /6.006/assignments/1
  def show
    return bounce_user unless @assignment.can_read_schedule? current_user

    respond_to do |format|
      format.html  # show.html.erb
    end
  end

  # GET /6.006/assignments/1/dashboard
  def dashboard
    @assignment = current_course.assignments.where(id: params[:id]).
        includes(:deliverables, submissions: :subject).first

    @recitation_sections = @assignment.course.recitation_sections

    respond_to do |format|
      format.html  # dashboard.html.erb
    end
  end

  # GET /6.006/assignments/new
  def new
    @assignment = Assignment.new course: current_course, author: current_user
    @assignment.due_at = @assignment.default_due_at
    @assignment.build_exam

    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  # GET /6.006/assignments/1/edit
  def edit
    @assignment.build_exam unless @assignment.exam
  end

  # POST /6.006/assignments
  def create
    @assignment = Assignment.new assignment_params
    @assignment.course = current_course
    @assignment.scheduled = false
    @assignment.grades_released = false

    respond_to do |format|
      if @assignment.save
        format.html do
          redirect_to edit_assignment_url(@assignment,
                                          course_id: @assignment.course),
              notice: 'Assignment created.'
        end
      else
        format.html do
          @assignment.build_exam
          render :new
        end
      end
    end
  end

  # PATCH /6.006/assignments/1
  def update
    respond_to do |format|
      if @assignment.update assignment_params
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment updated.'
        end
      else
        format.html do
          @assignment.build_exam
          render :edit
        end
      end
    end
  end


  # DELETE /6.006/assignments/1
  def destroy
    @assignment.destroy

    respond_to do |format|
      format.html do
        redirect_to assignments_url(course_id, @assignment.course),
            notice: "Deleted assignment #{@assignment.name}"
      end
    end
  end

  # PATCH /6.006/assignments/1/schedule
  def schedule
    respond_to do |format|
      if @assignment.update scheduled: true
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment is now visible to students.'
        end
      else
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment could not be made visible to students.'
        end
      end
    end
  end

  # PATCH /6.006/assignments/1/deschedule
  def deschedule
    respond_to do |format|
      if @assignment.update scheduled: false, grades_released: false
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment hidden from students.'
        end
      else
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment could not be hidden from students.'
        end
      end
    end
  end

  # PATCH /6.006/assignments/1/release
  def release
    respond_to do |format|
      @assignment.scheduled = true
      @assignment.released_at = Time.current unless @assignment.released?
      if @assignment.save
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment unlocked.'
        end
      else
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment could not be unlocked.'
        end
      end
    end
  end

  # PATCH /6.006/assignments/1/unrelease
  def unrelease
    respond_to do |format|
      if @assignment.update released_at: nil, grades_released: false
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment locked.'
        end
      else
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment could not be locked.'
        end
      end
    end
  end

  # PATCH /6.006/assignments/1/release_grades
  def release_grades
    @assignment.scheduled = true
    @assignment.released_at = Time.current unless @assignment.released?
    @assignment.grades_released = true

    respond_to do |format|
      if @assignment.save
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Grades are now visible to students.'
        end
      else
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Grades could not be made visible to students.'
        end
      end
    end
  end

  def set_assignment
    @assignment = current_course.assignments.find params[:id]
  end
  private :set_assignment

  # NOTE: We allow the :id parameter in the has_many association's attributes
  #     hash since accepts_nested_attributes_for checks that each nested record
  #     actually belongs to the parent record.
  def assignment_params
    exam_session_params = [:id, :name, :starts_at, :ends_at, :capacity,
        :_destroy]
    exam_params = [:id, :requires_confirmation,
        { exam_sessions_attributes: exam_session_params }]
    analyzer_params = [:id, :type, :message_name, :auto_grading, :time_limit,
        :ram_limit, :file_limit, :file_size_limit, :process_limit,
        :map_time_limit, :map_ram_limit, :map_logs_limit, :reduce_time_limit,
        :reduce_ram_limit, :reduce_logs_limit, { db_file_attributes: :f }]
    deliverable_params = [:name, :_destroy, :description, :id,
        { analyzer_attributes: analyzer_params } ]
    file_params = [:id, :description, :released_at, :_destroy,
        :reset_released_at, { db_file_attributes: :f }]
    metric_params = [:name, :max_score, :weight, :id, :_destroy]
    params.require(:assignment).permit :name, :due_at, :weight, :author_exuid,
        :team_partition_id, :feedback_survey_id, :scheduled, :released_at,
        :reset_released_at, :grades_released, :enable_exam,
        exam_attributes: exam_params,
        deliverables_attributes: deliverable_params,
        files_attributes: file_params, metrics_attributes: metric_params
    # Note: feedback_survey_id is protected in the model but is allowed here
  end
  private :assignment_params
end
