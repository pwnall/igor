class SurveyAnswersController < ApplicationController
  before_filter :authenticated_as_user, :except => [:index, :show, :destroy]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destory]  

  # GET /survey_answers
  # GET /survey_answers.xml
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
      format.xml  { render :xml => @survey_answers }
    end
  end

  # GET /survey_answers/1
  # GET /survey_answers/1.xml
  def show
    @survey_answer = SurveyAnswer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_answer }
    end
  end
  
  # GET /survey_answers/new
  # GET /survey_answers/new.xml
  def new
    assignment = Assignment.find(params[:assignment_id])
    @survey_answer = SurveyAnswer.
        where(:assignment_id => assignment.id, :user_id => @s_user.id).first
        
    unless @survey_answer
      @survey_answer = SurveyAnswer.new :assignment => assignment,
                                        :user => @s_user
      @survey_answer.create_answers
    end
    
    new_edit
  end

  # GET /survey_answers/1/edit
  def edit
    @survey_answer = SurveyAnswer.find(params[:id])
    if @survey_answer.user_id != @s_user.id
      return bounce_user("This isn't yours to play with! Your attempt has been logged.")
    end
    
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @survey_answer }
    end    
  end

  # POST /survey_answers
  # POST /survey_answers.xml
  def create
    @survey_answer = SurveyAnswer.new(params[:survey_answer])
    @survey_answer.user = @s_user
    create_update    
  end

  # PUT /survey_answerss/1
  # PUT /survey_answerss/1.xml
  def update
    @survey_answer = SurveyAnswer.find(params[:id])
    if @survey_answer.user_id != @s_user.id
      return bounce_user("This isn't yours to play with! Your attempt has been logged.")
    end

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
        format.xml do
          if is_new_record
            render :xml => @survey_answer, :status => :created, :location => @survey_answer
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @survey_answer.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # DELETE /survey_answers/1
  # DELETE /survey_answers/1.xml
  def destroy
    @survey_answer = SurveyAnswer.find(params[:id])
    @survey_answer.destroy

    respond_to do |format|
      format.html { redirect_to survey_answers_path }
      format.xml  { head :ok }
    end
  end
end