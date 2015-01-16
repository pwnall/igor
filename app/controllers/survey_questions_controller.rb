class SurveyQuestionsController < ApplicationController
  before_action :authenticated_as_admin

  # GET /survey_questions
  def index
    @surveys = Survey.all
    @survey_questions = SurveyQuestion.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /survey_questions/1
  def show
    @survey_question = SurveyQuestion.find params[:id]

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /survey_questions/new
  def new
    @survey_question = SurveyQuestion.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /survey_questions/1/edit
  def edit
    @survey_question = SurveyQuestion.find params[:id]
  end

  # POST /survey_questions
  def create
    @survey_question = SurveyQuestion.new survey_question_params

    respond_to do |format|
      if @survey_question.save
        format.html { redirect_to(survey_questions_path, :notice => 'Survey Question was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /survey_questions/1
  def update
    @survey_question = SurveyQuestion.find params[:id]

    respond_to do |format|
      if @survey_question.update_attributes survey_question_params
        format.html { redirect_to(survey_questions_path, :notice => 'Feedback Question was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /survey_questions/1
  def destroy
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.destroy

    respond_to do |format|
      format.html { redirect_to(survey_questions_path) }
    end
  end

  # Permits creating and updating survey questions.
  def survey_question_params
    params.require(:survey_question).permit :human_string, :targets_user, :allows_comments, :scaled, :scale_min, :scale_max, :scale_min_label, :scale_max_label
  end
  private :survey_question_params

end
