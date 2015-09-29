class AssignmentsController < ApplicationController
  include SidebarLayout

  before_action :set_current_course
  before_action :authenticated_as_course_editor, except: [:index, :show]
  before_action :authenticated_as_user, only: [:index, :show]
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

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
    return bounce_user unless @assignment.can_read? current_user

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

    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  # GET /6.006/assignments/1/edit
  def edit
  end

  # POST /6.006/assignments
  def create
    @assignment = Assignment.new assignment_params
    @assignment.course = current_course
    @assignment.deliverables_ready = false
    @assignment.metrics_ready = false

    respond_to do |format|
      if @assignment.save
        format.html do
          redirect_to edit_assignment_url(@assignment,
                                          course_id: @assignment.course),
              notice: 'Assignment created.'
        end
      else
        format.html { render :new }
      end
    end
  end

  # PUT /6.006/assignments/1
  def update
    respond_to do |format|
      if @assignment.update_attributes assignment_params
        format.html do
          redirect_to dashboard_assignment_url(@assignment,
                                               course_id: @assignment.course),
              notice: 'Assignment updated.'
        end
      else
        format.html { render :edit }
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

  def set_assignment
    @assignment = current_course.assignments.find params[:id]
  end
  private :set_assignment

  # NOTE: We allow the :id parameter in the has_many association's attributes
  #     hash since accepts_nested_attributes_for checks that each nested record
  #     actually belongs to the parent record.
  def assignment_params
    params.require(:assignment).permit :name, :due_at, :weight, :author_id,
        :team_partition_id, :feedback_survey_id,
        :deliverables_ready, :metrics_ready,
        deliverables_attributes: [:name, :file_ext, :_destroy,
            :description, :id, { analyzer_attributes: [:id, :type,
                :message_name, :auto_grading, :time_limit, :ram_limit,
                :file_limit, :file_size_limit, :process_limit,
                :map_time_limit, :map_ram_limit, :reduce_time_limit,
                :reduce_ram_limit,
                { db_file_attributes: :f }] } ],
        files_attributes: [:id, :description, :published_at, :_destroy,
            { db_file_attributes: :f }],
        metrics_attributes: [:name, :max_score, :weight, :id, :_destroy]
    # Note: feedback_survey_id is protected in the model but is allowed here
  end
  private :assignment_params
end
