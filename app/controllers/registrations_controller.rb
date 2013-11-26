class RegistrationsController < ApplicationController
  before_filter :authenticated_as_user, :only => [:new, :create, :edit, :update, :new_or_edit]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destroy]
   
  # GET /registrations
  def index
    @prerequisites = Prerequisite.all
    @registrations = Registration.all
    @leaders = User.find(:all, conditions: { admin: true }, include: :profile)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /registrations/1
  def show
    @registration = Registration.find params[:id]
    @recitation_conflicts =
        @registration.recitation_conflicts.index_by(&:timeslot)

    respond_to do |format|
      format.html
    end
  end

  def new_edit
    prepare_for_editing

    # Disallow random record updates.
    unless @registration.can_edit? current_user
      notice[:error] = 'That is not yours to play with! Attempt logged.'
      redirect_to root_path
      return
    end
    
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.js   { render :action => :edit }
    end    
  end
  private :new_edit
  
  def prepare_for_editing
    @prerequisites = @registration.prerequisite_answers.
                                   index_by(&:prerequisite_id)
    Prerequisite.all.each do |prereq|
      next if @prerequisites.has_key? prereq.id
      @prerequisites[prereq.id] =
          @registration.prerequisite_answers.build(:prerequisite => prereq)
    end

    @recitation_conflicts =
        @registration.recitation_conflicts.index_by &:timeslot
  end
  private :prepare_for_editing
    
  # GET /registrations/new
  def new
    user = User.find params[:user_id]
    course = Course.find params[:course_id]
    @registration = Registration.new :user => user, :course => course
    new_edit
  end

  # GET /registrations/1/edit
  def edit
    @registration = Registration.find params[:id]
    new_edit
  end
  
  def create_update
    unless @registration.can_edit? current_user
      # Disallow random record updates.
      notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
      redirect_to root_path
      return
    end
    
    if @new_record = @registration.new_record?
      success = @registration.save
    else
      if params.has_key? :recitation_section
        @registration.recitation_section = RecitationSection.where(serial: params[:recitation_section][:serial]).first
        success = @registration.save
      elsif params.has_key? :recitation_conflicts
        @registration.update_conflicts params[:recitation_conflicts]
      else
        success = @registration.update_attributes params[:registration]
      end
      
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Student Information successfully #{@new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to @registration }
        format.js { head :ok }
      else
        prepare_for_editing
        format.html { render :action => :new_edit }
        format.js   { render :action => :edit }
      end
    end    
  end

  # POST /registrations
  def create
    @registration = Registration.new params[:registration]
    create_update
  end

  # PUT /registrations/1
  def update
    @registration = Registration.find params[:id]
    create_update
  end
  
  # DELETE /registrations/1
  def destroy
    @registration = Registration.find params[:id]
    @registration.destroy

    respond_to do |format|
      format.html { redirect_to(registrations_url) }
    end
  end

  private 
    # Permit update recitation conflicts
    def registration_update_params
      params[:registration].permit :course_id, :for_credit, :allows_publishing
      # TODO(mingy): fill in once update_page is fixed
    end 

end
