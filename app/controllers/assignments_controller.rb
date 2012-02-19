class AssignmentsController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:index, :show]
  before_filter :authenticated_as_user, :only => [:index, :show]

  layout lambda { |controller|
    controller.current_user.try(:admin?) ? 'assignments' : 'session'
  }

  # GET /assignments
  def index
    @assignments = Assignment.for current_user, Course.main

    respond_to do |format|
      format.html  # index.html.erb
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
    @assignment.course = Course.main
    @assignment.author = current_user
    
    respond_to do |format|
      format.html  # new.html.erb
    end    
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
  end
  
  # POST /assignments
  def create
    @assignment = Course.main.assignments.build params[:assignment]

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to edit_assignment_path(@assignment) }
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
