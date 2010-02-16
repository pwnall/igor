class FeedbackAnswersController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /feedback_answers
  # GET /feedback_answers.xml
  def index
    @feedback_answers = FeedbackAnswer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedback_answers }
    end
  end

  # GET /feedback_answers/1
  # GET /feedback_answers/1.xml
  def show
    @feedback_answer = FeedbackAnswer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback_answer }
    end
  end

  # GET /feedback_answers/new
  # GET /feedback_answers/new.xml
  def new
    @feedback_answer = FeedbackAnswer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback_answer }
    end
  end

  # GET /feedback_answers/1/edit
  def edit
    @feedback_answer = FeedbackAnswer.find(params[:id])
  end

  # POST /feedback_answers
  # POST /feedback_answers.xml
  def create
    @feedback_answer = FeedbackAnswer.new(params[:feedback_answer])

    respond_to do |format|
      if @feedback_answer.save
        format.html { redirect_to(@feedback_answer, :notice => 'FeedbackAnswer was successfully created.') }
        format.xml  { render :xml => @feedback_answer, :status => :created, :location => @feedback_answer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback_answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedback_answers/1
  # PUT /feedback_answers/1.xml
  def update
    @feedback_answer = FeedbackAnswer.find(params[:id])

    respond_to do |format|
      if @feedback_answer.update_attributes(params[:feedback_answer])
        format.html { redirect_to(@feedback_answer, :notice => 'FeedbackAnswer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback_answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedback_answers/1
  # DELETE /feedback_answers/1.xml
  def destroy
    @feedback_answer = FeedbackAnswer.find(params[:id])
    @feedback_answer.destroy

    respond_to do |format|
      format.html { redirect_to(feedback_answers_url) }
      format.xml  { head :ok }
    end
  end
end
