class RegistrationsController < ApplicationController
  before_filter :authenticated_as_user, :only => [:new, :create, :edit, :update, :new_or_edit]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destroy]
   
  # GET /registrations
  # GET /registrations.xml
  def index
    @prerequisites = Prerequisite.all
    @registrations = Registration.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registrations }
    end
  end

  # GET /registrations/1
  # GET /registrations/1.xml
  def show
    @registration = Registration.find(params[:id])
    @recitation_conflicts =
        @registration.recitation_conflicts.index_by &:timeslot

    respond_to do |format|
      format.html
      format.xml  { render :xml => @registration }
    end
  end

  def new_edit
    prepare_for_editing

    # Disallow random record updates.
    unless @registration.editable_by_user? @s_user
      notice[:error] = 'That is not yours to play with! Attempt logged.'
      redirect_to root_path
      return
    end
    
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.js   { render :action => :edit }
      format.xml  { render :xml => @registration }
    end    
  end
  private :new_edit
  
  def prepare_for_editing
    @prerequisites = @registration.prerequisite_answers.index_by &:prerequisite_id
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
  # GET /registrations/new.xml
  def new
    user = User.find params[:user_id]
    course = Course.find params[:course_id]
    @registration = Registration.new :user => user, :course => course
    new_edit
  end

  # GET /registrations/1/edit
  def edit
    @registration = Registration.find(params[:id])
    new_edit
  end
  
  def create_update
    if !@registration.editable_by_user?(@s_user)
      # Disallow random record updates.
      notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
      redirect_to root_path
      return
    end
    
    if Course.main.has_recitations?
      old_recitation_conflicts =
          @registration.recitation_conflicts.index_by &:timeslot
      Rails.logger.warn old_recitation_conflicts.inspect
      
      # Update recitation conflicts.
      params[:recitation_conflicts].each_value do |rc|
        next if rc[:class_name].blank?
        timeslot = rc[:timeslot].to_i
        if old_recitation_conflicts.has_key? timeslot
          old_recitation_conflicts.delete(timeslot).update_attributes rc
        else
          rc[:registration] = @registration
          conflict = RecitationConflict.new(rc)
          @registration.recitation_conflicts << conflict
        end
      end
      # Wipe cleared conflicts.
      old_recitation_conflicts.each_value { |orc| @registration.recitation_conflicts.delete orc }
    end
    
    if @new_record = @registration.new_record?
      success = @registration.save!
    else
      # Disallow structural changes to the record.
      params[:registration].delete :user_id
      params[:registration].delete :course_id
      
      success = @registration.update_attributes(params[:registration])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Student Information successfully #{@new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to @registration.user }
        format.js   { render :action => :create_update }
        format.xml do
          if is_new_record
            render :xml => @registration, :status => :created, :location => @registration
          else
            head :ok
          end  
        end  
      else
        prepare_for_editing
        format.html { render :action => :new_edit }
        format.js   { render :action => :edit }
        format.xml  { render :xml => @registration.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # POST /registrations
  # POST /registrations.xml
  def create
    @registration = Registration.new(params[:registration])
    create_update
  end

  # PUT /registrations/1
  # PUT /registrations/1.xml
  def update
    @registration = Registration.find(params[:id])
    create_update
  end
  
  # DELETE /registrations/1
  # DELETE /registrations/1.xml
  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy

    respond_to do |format|
      format.html { redirect_to(registrations_url) }
      format.xml  { head :ok }
    end
  end
end
