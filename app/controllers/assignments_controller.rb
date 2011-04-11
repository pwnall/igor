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
    @assignment.deliverables.build
    @assignment.metrics.build
    
    respond_to do |format|
      format.html  # new.html.erb
    end    
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
    @assignment.deliverables.build
    @assignment.metrics.build
  end
  
  # POST /assignments
  def create
    @assignment = Assignment.new(params[:assignment])

    respond_to do |format|
      if @assignment.save
        format.html do
          redirect_to @assignment, :notice => 'Assignment successfully created.'
        end
      else
        format.html { render :action => :new }
      end
    end
  end

  # PUT /assignments/1
  def update
    @assignment = Assignment.find(params[:id])

    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html do
          redirect_to @assignment, :notice => 'Assignment successfully updated.'
        end
      else
        format.html { render :action => :edit }
      end
    end
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
