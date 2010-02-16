class FeedbackQuestionsController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /feedback_questions
  # GET /feedback_questions.xml
  def index
    @feedback_question_sets = FeedbackQuestionSet.all
    @feedback_questions = FeedbackQuestion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedback_questions }
    end
  end

  # GET /feedback_questions/1
  # GET /feedback_questions/1.xml
  def show
    @feedback_question = FeedbackQuestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback_question }
    end
  end

  # GET /feedback_questions/new
  # GET /feedback_questions/new.xml
  def new
    @feedback_question = FeedbackQuestion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback_question }
    end
  end

  # GET /feedback_questions/1/edit
  def edit
    @feedback_question = FeedbackQuestion.find(params[:id])
  end

  # POST /feedback_questions
  # POST /feedback_questions.xml
  def create
    @feedback_question = FeedbackQuestion.new(params[:feedback_question])

    respond_to do |format|
      if @feedback_question.save
        format.html { redirect_to(@feedback_question, :notice => 'FeedbackQuestion was successfully created.') }
        format.xml  { render :xml => @feedback_question, :status => :created, :location => @feedback_question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedback_questions/1
  # PUT /feedback_questions/1.xml
  def update
    @feedback_question = FeedbackQuestion.find(params[:id])

    respond_to do |format|
      if @feedback_question.update_attributes(params[:feedback_question])
        format.html { redirect_to(@feedback_question, :notice => 'FeedbackQuestion was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedback_questions/1
  # DELETE /feedback_questions/1.xml
  def destroy
    @feedback_question = FeedbackQuestion.find(params[:id])
    @feedback_question.destroy

    respond_to do |format|
      format.html { redirect_to(feedback_questions_url) }
      format.xml  { head :ok }
    end
  end
end
