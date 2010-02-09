class StudentInfosController < ApplicationController
  before_filter :authenticated_as_user, :only => [:new, :create, :edit, :update, :new_or_edit]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destroy]
   
  # GET /student_infos
  # GET /student_infos.xml
  def index
    @prerequisites = Prerequisite.all
    @student_infos = StudentInfo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @student_infos }
    end
  end

  # GET /student_infos/1
  # GET /student_infos/1.xml
  def show
    @student_info = StudentInfo.find(params[:id])
    @recitation_conflicts =
        @student_info.recitation_conflicts.index_by &:timeslot

    respond_to do |format|
      format.html
      format.xml  { render :xml => @student_info }
    end
  end

  def new_edit(manual)
    prepare_for_editing

    @manual = manual
    unless @student_info.new_record?
      if !@s_user.admin && (@s_user.id != @student_info.user_id)
        # Do not allow random record updates.
        notice[:error] =
            'That is not yours to play with! Your attempt has been logged.'
        redirect_to root_path
        return
      end
    end
    
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @student_info }
    end    
  end
  private :new_edit
  
  def prepare_for_editing
    @prerequisites = @student_info.prerequisite_answers.index_by &:prerequisite_id
    Prerequisite.all.each do |prereq|
      next if @prerequisites.has_key? prereq.id
      @prerequisites[prereq.id] =
          @student_info.prerequisite_answers.build(:prerequisite => prereq)
    end

    @recitation_conflicts =
        @student_info.recitation_conflicts.index_by &:timeslot
  end
  private :prepare_for_editing
  
  # GET /student_infos/for_myself
  def my_own
    if @s_user.student_info
      # the user has a student_info, so hack it into the request
      params[:id] = @s_user.student_info.id
      edit
    else
      new
    end
  end
  
  # GET /student_infos/new
  # GET /student_infos/new.xml
  def new
    @student_info = StudentInfo.new
    new_edit(false)
  end

  # GET /student_infos/1/edit
  def edit
    @student_info = StudentInfo.find(params[:id])
    new_edit(false)
  end
  
  def new_manual
    @student_info = StudentInfo.new
    new_edit(true)    
  end
    
  def create_update(manual)
    @manual = manual
    
    is_new_record = @student_info.new_record?
    if is_new_record
      @student_info.user = manual ? @new_user : @s_user       
    else
      if !@s_user.admin && @s_user.id != @student_info.user_id
        # Do not allow random record updates.
        notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
        redirect_to root_path
        return
      end
    end
    
    if Course.main.has_recitations?
      old_recitation_conflicts =
          @student_info.recitation_conflicts.index_by &:timeslot
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
          @student_info.recitation_conflicts << RecitationConflict.new(rc)
        end
      end
      # wipe cleared conflicts
      old_recitation_conflicts.each_value { |orc| @student_info.recitation_conflicts.delete orc }
    end
    
    if is_new_record
      success = @student_info.save
    else
      success = @student_info.update_attributes(params[:student_info])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Student Information successfully #{is_new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to root_path }
        format.xml do
          if is_new_record
            render :xml => @student_info, :status => :created, :location => @student_info
          else
            head :ok
          end  
        end  
      else
        prepare_for_editing
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @student_info.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # POST /student_infos
  # POST /student_infos.xml
  def create
    @student_info = StudentInfo.new(params[:student_info])
    create_update(false)    
  end

  # PUT /student_infos/1
  # PUT /student_infos/1.xml
  def update
    @student_info = StudentInfo.find(params[:id])
    create_update(false)
  end
  
  def create_manual
    @new_user = User.new(:name => "dummy_#{Time.now.to_i}", :password => 'superdummy', :email => 'costan@mit.edu', :active => false, :admin => false)
    @new_user.save!

    @student_info = StudentInfo.new(params[:student_info])
    create_update(true)
  end

  # DELETE /student_infos/1
  # DELETE /student_infos/1.xml
  def destroy
    @student_info = StudentInfo.find(params[:id])
    @student_info.destroy

    respond_to do |format|
      format.html { redirect_to(student_infos_url) }
      format.xml  { head :ok }
    end
  end
end
