class SurveyResponsesController < ApplicationController
  include SidebarLayout

  before_action :set_current_course
  before_action :authenticated_as_user, except: [:index]
  before_action :authenticated_as_course_editor, only: [:index]
  before_action :set_survey, only: [:index, :create]

  # GET /6.006/surveys/1/responses
  def index
  end

  # POST /6.006/surveys/1/responses
  def create
    @response = SurveyResponse.new survey_response_params
    @response.survey = @survey
    @response.user = current_user

    respond_to do |format|
      if @response.save
        format.html do
          redirect_to survey_url(@survey, course_id: @survey.course),
              notice: "Saved response to survey: #{@survey.name}."
        end
      else
        format.html do
          render 'surveys/show'
        end
      end
    end
  end

  # PATCH /6.006/responses/1
  def update
    @response = current_course.survey_responses.find params[:id]
    return bounce_user unless @response.can_edit? current_user

    respond_to do |format|
      if @response.update survey_response_params
        format.html do
          redirect_to survey_url(@response.survey,
              course_id: @response.survey.course),
              notice: "Updated response to survey: #{@response.survey.name}."
        end
      else
        format.html do
          @survey = @response.survey
          render 'surveys/show'
        end
      end
    end
  end

  def set_survey
    @survey = current_course.surveys.find params[:survey_id]
    return bounce_user unless @survey.can_respond? current_user
  end
  private :set_survey

  # NOTE: We allow the :id parameter in the has_many association's attributes
  #     hash since accepts_nested_attributes_for checks that each nested record
  #     actually belongs to the parent record.
  def survey_response_params
    params.require(:survey_response).permit answers_attributes: [:id, :_destroy,
        :question_id, :number, :comment]
  end
end
