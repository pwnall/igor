class AssignmentFeedbacksController < ApplicationController
  before_filter :authenticated_as_user, :except => [:index, :show, :destroy]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destory]  

  # GET /assignment_feedbacks
  # GET /assignment_feedbacks.xml
  def index
    if params[:assignment_id]
      @assignment = Assignment.find(params[:assignment_id])
      @assignment_feedbacks = AssignmentFeedback.find(:all, :conditions => {:assignment_id => params[:assignment_id]}, :include => [{:user => :profile}])
    else 
      @assignment_feedbacks = AssignmentFeedback.find(:all, :include => [{:user => :profile}])
    end
    @assignments = Assignment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assignment_feedbacks }
    end
  end

  # GET /assignment_feedbacks/1
  # GET /assignment_feedbacks/1.xml
  def show
    @assignment_feedback = AssignmentFeedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assignment_feedback }
    end
  end
  
  # GET /assignment_feedbacks/new
  # GET /assignment_feedbacks/new.xml
  def new
    assignment = Assignment.find(params[:assignment_id])
    @assignment_feedback = AssignmentFeedback.first :conditions =>
        {:assignment_id => assignment.id, :user_id => @s_user.id}
    @assignment_feedback ||= AssignmentFeedback.new
    @assignment_feedback.assignment = assignment
    
    new_edit
  end

  # GET /assignment_feedbacks/1/edit
  def edit
    @assignment_feedback = AssignmentFeedback.find(params[:id])
    if @assignment_feedback.user_id != @s_user.id
      return bounce_user("This isn't yours to play with! Your attempt has been logged.")
    end
    
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @assignment_feedback }
    end    
  end

  # POST /assignment_feedbacks
  # POST /assignment_feedbacks.xml
  def create
    @assignment_feedback = AssignmentFeedback.new(params[:assignment_feedback])
    @assignment_feedback.user = @s_user
    create_update    
  end

  # PUT /assignment_feedbackss/1
  # PUT /assignment_feedbackss/1.xml
  def update
    @assignment_feedback = AssignmentFeedback.find(params[:id])
    if @assignment_feedback.user_id != @s_user.id
      return bounce_user("This isn't yours to play with! Your attempt has been logged.")
    end

    # updating is not allowed to move feedback around assignments
    params[:assignment_feedback].delete :assignment_id 
    create_update
  end

  def create_update
    @is_new_record = @assignment_feedback.new_record?
    if @is_new_record
      success = @assignment_feedback.save
    else
      success = @assignment_feedback.update_attributes(params[:assignment_feedback])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Feedback for #{@assignment_feedback.assignment.name} successfully #{@is_new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to root_path }
        format.xml do
          if is_new_record
            render :xml => @assignment_feedback, :status => :created, :location => @assignment_feedback
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @assignment_feedback.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # DELETE /assignment_feedbacks/1
  # DELETE /assignment_feedbacks/1.xml
  def destroy
    @assignment_feedback = AssignmentFeedback.find(params[:id])
    @assignment_feedback.destroy

    respond_to do |format|
      format.html { redirect_to(assignment_feedbacks_url) }
      format.xml  { head :ok }
    end
  end
end
