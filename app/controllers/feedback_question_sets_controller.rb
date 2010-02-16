class FeedbackQuestionSetsController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /feedback_question_sets
  # GET /feedback_question_sets.xml
  def index
    @feedback_question_sets = FeedbackQuestionSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedback_question_sets }
    end
  end

  # GET /feedback_question_sets/1
  # GET /feedback_question_sets/1.xml
  def show
    @feedback_question_set = FeedbackQuestionSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback_question_set }
    end
  end

  # GET /feedback_question_sets/new
  # GET /feedback_question_sets/new.xml
  def new
    @feedback_question_set = FeedbackQuestionSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback_question_set }
    end
  end

  # GET /feedback_question_sets/1/edit
  def edit
    @feedback_question_set = FeedbackQuestionSet.find(params[:id])
    @feedback_questions = FeedbackQuestion.all
  end

  # POST /feedback_question_sets
  # POST /feedback_question_sets.xml
  def create
    @feedback_question_set = FeedbackQuestionSet.new(params[:feedback_question_set])

    respond_to do |format|
      if @feedback_question_set.save
        format.html { redirect_to edit_feedback_question_set_path(@feedback_question_set) }
        format.xml  { render :xml => @feedback_question_set, :status => :created, :location => @feedback_question_set }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback_question_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedback_question_sets/1
  # PUT /feedback_question_sets/1.xml
  def update
    @feedback_question_set = FeedbackQuestionSet.find(params[:id])

    respond_to do |format|
      if @feedback_question_set.update_attributes(params[:feedback_question_set])
        format.html { redirect_to(feedback_questions_path, :notice => 'FeedbackQuestionSet was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback_question_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedback_question_sets/1
  # DELETE /feedback_question_sets/1.xml
  def destroy
    @feedback_question_set = FeedbackQuestionSet.find(params[:id])
    @feedback_question_set.destroy

    respond_to do |format|
      format.html { redirect_to feedback_questions_path }
      format.xml  { head :ok }
    end
  end
  
  # POST /feedback_question_sets/question
  def add_question
    @feedback_question_set = FeedbackQuestionSet.find(params[:id])
    question = FeedbackQuestion.find(params[:question_id])
    
    FeedbackQuestionSetMembership.create :feedback_question => question,
        :feedback_question_set => @feedback_question_set
    
    redirect_to edit_feedback_question_set_path(@feedback_question_set)
  end

  # DELETE /feedback_question_sets/question
  def remove_question
    @feedback_question_set = FeedbackQuestionSet.find(params[:id])
    membership = @feedback_question_set.memberships.first(:conditions => {
        :feedback_question_id => params[:question_id]})
    membership.destroy
    
    redirect_to edit_feedback_question_set_path(@feedback_question_set)    
  end
end
