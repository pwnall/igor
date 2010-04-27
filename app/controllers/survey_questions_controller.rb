class SurveyQuestionsController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /survey_questions
  # GET /survey_questions.xml
  def index
    @surveys = Survey.all
    @survey_questions = SurveyQuestion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_questions }
    end
  end

  # GET /survey_questions/1
  # GET /survey_questions/1.xml
  def show
    @survey_question = SurveyQuestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_question }
    end
  end

  # GET /survey_questions/new
  # GET /survey_questions/new.xml
  def new
    @survey_question = SurveyQuestion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_question }
    end
  end

  # GET /survey_questions/1/edit
  def edit
    @survey_question = SurveyQuestion.find(params[:id])
  end

  # POST /survey_questions
  # POST /survey_questions.xml
  def create
    @survey_question = SurveyQuestion.new(params[:survey_question])

    respond_to do |format|
      if @survey_question.save
        format.html { redirect_to(survey_questions_path, :notice => 'Survey Question was successfully created.') }
        format.xml  { render :xml => @survey_question, :status => :created, :location => @survey_question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_questions/1
  # PUT /survey_questions/1.xml
  def update
    @survey_question = SurveyQuestion.find(params[:id])

    respond_to do |format|
      if @survey_question.update_attributes(params[:survey_question])
        format.html { redirect_to(survey_questions_path, :notice => 'Feedback Question was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_questions/1
  # DELETE /survey_questions/1.xml
  def destroy
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.destroy

    respond_to do |format|
      format.html { redirect_to(survey_questions_path) }
      format.xml  { head :ok }
    end
  end
end
