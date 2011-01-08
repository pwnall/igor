class AssignmentsController < ApplicationController
  before_filter :authenticated_as_admin
    
  in_place_edit_for :assignment, :name


  # GET /assignments
  def index
    @assignments = Assignment.find(:all, :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /assignments/1
  def show
    @assignment = Assignment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
    new_edit
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit } # new_edit.html.erb
      format.js   { render :action => :new_edit } # new_edit.js.rjs 
    end    
  end
  
  def create_update
    @new_record = @assignment.new_record?
    @div_id = @new_record ? params[:div_id] : @assignment.id
    
    @success = @new_record ? @assignment.save : @assignment.update_attributes(params[:assignment])
    respond_to do |format|
      format.js do
        render :action => 'create_update'          
      end
      if @success
        format.html do
          flash[:notice] = "Assignment was successfully #{@new_record ? 'created' : 'updated'}."
          redirect_to assignments_path
        end
      else
        format.html do
          flash[:notice] = "Assignment #{@new_record ? 'creation' : 'update'} failed."
          render :action => :new_edit
        end
      end
    end
  end


  # POST /assignments
  def create
    @assignment = Assignment.new(params[:assignment])
    create_update
  end
  
  # PUT /assignments/1
  def update
    @assignment = Assignment.find(params[:id])
    create_update
  end
  
  # DELETE /assignments/1
  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to(assignments_url) }
      format.js do
        render :update do |page|
          add_site_status page, "Assignment #{@assignment.name} destroyed", true
          page.visual_effect :fade, "assignment_row_#{@assignment.id}"
        end
      end
    end
  end
end
