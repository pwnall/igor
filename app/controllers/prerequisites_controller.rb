class PrerequisitesController < ApplicationController
  before_action :authenticated_as_course_editor
  before_action :set_prerequisite, only: [:edit, :update, :destroy]

  # GET /prerequisites
  def index
    @prerequisites = current_course.prerequisites

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /prerequisites/new
  def new
    @prerequisite = Prerequisite.new course: current_course
  end

  # GET /prerequisites/1/edit
  def edit
  end

  # POST /prerequisites
  def create
    @prerequisite = Prerequisite.new prerequisite_params
    @prerequisite.course = current_course
    respond_to do |format|
      if @prerequisite.save
        format.html do
          redirect_to prerequisites_url, :notice => 'Prerequisite created.'
        end
      else
        format.html { render :action => :new }
      end
    end
  end

  # PUT /prerequisites/1
  def update
    respond_to do |format|
      if @prerequisite.update_attributes prerequisite_params
        format.html do
          redirect_to prerequisites_url, :notice => 'Prerequisite updated.'
        end
      else
        format.html { render :action => :edit }
      end
    end
  end

  # DELETE /prerequisites/1
  def destroy
    @prerequisite.destroy

    notice = "Prerequisite #{@prerequisite.prerequisite_number} removed."
    respond_to do |format|
      format.html { redirect_to prerequisites_url, :notice => notice }
    end
  end

  # Common code for fetching the prerequisite.
  def set_prerequisite
    @prerequisite = current_course.prerequisites.find params[:id]
  end

  # Permits creating and updating prerequisites.
  def prerequisite_params
    params[:prerequisite].permit :prerequisite_number, :waiver_question
  end
  private :prerequisite_params

end
