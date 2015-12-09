class SurveysController < ApplicationController
  include SidebarLayout

  before_action :set_current_course
  before_action :authenticated_as_user, only: [:index, :show]
  before_action :authenticated_as_course_editor, except: [:index, :show]
  before_action :set_survey, only: [:show, :edit, :update, :destroy]

  # GET /surveys
  def index
    @surveys = current_course.surveys_for current_user

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /surveys/1
  def show
    return bounce_user unless @survey.can_submit? current_user

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /surveys/new
  def new
    @survey = Survey.new course: current_course
    @survey.due_at = @survey.default_due_at

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /surveys/1/edit
  def edit
  end

  # POST /surveys
  def create
    @survey = Survey.new survey_params
    @survey.course = current_course
    @survey.released = false

    respond_to do |format|
      if @survey.save
        format.html do
          redirect_to edit_survey_url(@survey, course_id: @survey.course)
        end
      else
        format.html { render :new }
      end
    end
  end

  # PUT /surveys/1
  def update
    respond_to do |format|
      if @survey.update survey_params
        format.html do
          redirect_to surveys_url(course_id: @survey.course),
              notice: 'Survey was successfully updated.'
        end
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /surveys/1
  def destroy
    respond_to do |format|
      if @survey.can_delete? current_user
        @survey.destroy
        format.html do
          redirect_to surveys_url(course_id: @survey.course),
              notice: 'Survey was deleted.'
        end
      else
        format.html do
          redirect_to surveys_url(course_id: @survey.course),
              notice: 'Survey could not be deleted.'
        end
      end
    end
  end

  def set_survey
    @survey = current_course.surveys.find params[:id]
  end
  private :set_survey

  # NOTE: We allow the :id parameter in the has_many association's attributes
  #     hash since accepts_nested_attributes_for checks that each nested record
  #     actually belongs to the parent record.
  def survey_params
    params.require(:survey).permit :name, :released, :due_at,
        questions_attributes: [:id, :prompt, :_destroy, :type, :step_size,
        :allows_comments, :scaled, :scale_min, :scale_max, :scale_min_label,
        :scale_max_label ]
  end
  private :survey_params
end
