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

  def new_edit(manual)
    prepare_for_editing

    @manual = manual
    unless @registration.new_record?
      if !@s_user.admin && (@s_user.id != @registration.user_id)
        # Do not allow random record updates.
        notice[:error] =
            'That is not yours to play with! Your attempt has been logged.'
        redirect_to root_path
        return
      end
    end
    
    respond_to do |format|
      format.html { render :action => :new_edit }
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
  
  # GET /registrations/for_myself
  def my_own
    if @s_user.registration
      # the user has a registration, so hack it into the request
      params[:id] = @s_user.registration.id
      edit
    else
      new
    end
  end
  
  # GET /registrations/new
  # GET /registrations/new.xml
  def new
    @registration = Registration.new
    new_edit(false)
  end

  # GET /registrations/1/edit
  def edit
    @registration = Registration.find(params[:id])
    new_edit(false)
  end
  
  def new_manual
    @registration = Registration.new
    new_edit(true)    
  end
    
  def create_update(manual)
    @manual = manual
    
    is_new_record = @registration.new_record?
    if is_new_record
      @registration.user = manual ? @new_user : @s_user       
    else
      if !@s_user.admin && @s_user.id != @registration.user_id
        # Do not allow random record updates.
        notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
        redirect_to root_path
        return
      end
    end
    
    if Course.main.has_recitations?
      old_recitation_conflicts =
          @registration.recitation_conflicts.index_by &:timeslot
      # Update recitation conflicts.
      unless params[:old_recitation_conflicts].nil?
        params[:recitation_conflicts] += params[:old_recitation_conflicts].values
      end
      params[:recitation_conflicts].each do |rc|
        next if rc[:class_name].nil? || rc[:class_name].empty?
        timeslot = rc[:timeslot].to_i
        if old_recitation_conflicts[timeslot]
          old_recitation_conflicts[timeslot].class_name = rc[:class_name]
          old_recitation_conflicts.delete timeslot
        else
          @registration.recitation_conflicts << RecitationConflict.new(rc)
        end
      end
      # wipe cleared conflicts
      old_recitation_conflicts.each_value { |orc| @registration.recitation_conflicts.delete orc }
    end
    
    if is_new_record
      success = @registration.save
    else
      success = @registration.update_attributes(params[:registration])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Student Information successfully #{is_new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to root_path }
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
        format.xml  { render :xml => @registration.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # POST /registrations
  # POST /registrations.xml
  def create
    @registration = Registration.new(params[:registration])
    create_update(false)    
  end

  # PUT /registrations/1
  # PUT /registrations/1.xml
  def update
    @registration = Registration.find(params[:id])
    create_update(false)
  end
  
  def create_manual
    @new_user = User.new(:name => "dummy_#{Time.now.to_i}", :password => 'superdummy', :email => 'costan@mit.edu', :active => false, :admin => false)
    @new_user.save!

    @registration = Registration.new(params[:registration])
    create_update(true)
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
