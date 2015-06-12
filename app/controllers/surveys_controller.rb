class SurveysController < ApplicationController
  before_action :authenticated_as_admin

  # GET /surveys
  def index
    @surveys = Survey.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /surveys/1
  def show
    @survey = Survey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /surveys/new
  def new
    @survey = Survey.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /surveys/1/edit
  def edit
    @survey = Survey.find params[:id]
    @survey_questions = SurveyQuestion.all
  end

  # POST /surveys
  def create
    @survey = Survey.new survey_params
    @survey.published = false

    respond_to do |format|
      if @survey.save
        format.html { redirect_to edit_survey_path(@survey) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /surveys/1
  def update
    @survey = Survey.find params[:id]

    respond_to do |format|
      if @survey.update_attributes survey_params
        format.html { redirect_to(survey_questions_path, :notice => 'Survey was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /surveys/1
  def destroy
    @survey = Survey.find params[:id]
    @survey.destroy

    respond_to do |format|
      format.html { redirect_to surveys_path }
    end
  end

  # POST /surveys/question
  def add_question
    @survey = Survey.find params[:id]
    question = SurveyQuestion.find params[:question_id]

    SurveyQuestionMembership.create :survey_question => question,
        :survey => @survey

    redirect_to edit_survey_path @survey
  end

  # DELETE /surveys/question
  def remove_question
    @survey = Survey.find params[:id]
    membership = @survey.memberships.
        where(:survey_question_id => params[:question_id]).first
    membership.destroy

    redirect_to edit_survey_path @survey
  end

  # Permits creating and updating surveys.
  def survey_params
    params.require(:survey).permit :name
  end
  private :survey_params

end
