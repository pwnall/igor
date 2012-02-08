class SurveyAnswersController < ApplicationController
  before_filter :authenticated_as_user, :except => [:index, :show, :destroy]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destory]  

  # GET /survey_answers
  def index
    if params[:assignment_id]
      @assignment = Assignment.find(params[:assignment_id])
      @survey_answers = SurveyAnswer.
          where(:assignment_id => params[:assignment_id]).
          includes(:user => :profile)
    else
      @survey_answers = SurveyAnswer.includes(:user => :profile)
    end
    @assignments = Assignment.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /survey_answers/1
  def show
    @survey_answer = SurveyAnswer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # GET /survey_answers/new
  # GET /survey_answers/new?survey_answer[assignment_id]=3
  def new
    if params[:survey_answer] and params[:survey_answer][:assignment_id]
      assignment = Assignment.find params[:survey_answer][:assignment_id]

      @survey_answer = current_user.survey_answers.
                                    where(:assignment_id => assignment.id).first
        
      unless @survey_answer
        @survey_answer = SurveyAnswer.new :assignment => assignment,
                                          :user => current_user
        @survey_answer.create_question_answers
      end
    else
      assignment = nil
      @survey_answer = SurveyAnswer.new :user => current_user
    end
  
    new_edit
  end

  # GET /survey_answers/1/edit
  def edit
    @survey_answer = SurveyAnswer.find(params[:id])
    return bounce_user if @survey_answer.user_id != current_user.id
    
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.js   { render :action => :new_edit }
    end    
  end

  # POST /survey_answers
  def create
    @survey_answer = SurveyAnswer.new(params[:survey_answer])
    @survey_answer.user = current_user
    create_update    
  end

  # PUT /survey_answerss/1
  def update
    @survey_answer = SurveyAnswer.find(params[:id])
    return bounce_user if @survey_answer.user_id != current_user.id

    # updating is not allowed to move feedback around assignments
    params[:survey_answer].delete :assignment_id 
    create_update
  end

  def create_update
    @is_new_record = @survey_answer.new_record?
    if @is_new_record
      success = @survey_answer.save
    else
      success = @survey_answer.update_attributes(params[:survey_answer])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Feedback for #{@survey_answer.assignment.name} successfully #{@is_new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to root_path }
        format.js   { render :action => :create_update }
      else
        format.html { render :action => :new_edit }
        format.js   { render :action => :new_edit }
      end
    end    
  end

  # DELETE /survey_answers/1
  def destroy
    @survey_answer = SurveyAnswer.find(params[:id])
    @survey_answer.destroy

    respond_to do |format|
      format.html { redirect_to survey_answers_path }
    end
  end
end
