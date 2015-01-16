class PrerequisitesController < ApplicationController
  before_action :authenticated_as_admin, :except => [:new, :index, :show]

  # GET /prerequisites
  def index
    @prerequisites = Prerequisite.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /prerequisites/1
  def show
    @prerequisite = Prerequisite.find params[:id]

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /prerequisites/new
  def new
    @prerequisite = Prerequisite.new
  end

  # GET /prerequisites/1/edit
  def edit
    @prerequisite = Prerequisite.find params[:id]
  end

  # POST /prerequisites
  def create
    @prerequisite = Prerequisite.new prerequisite_params
    @prerequisite.course = Course.main
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
    @prerequisite = Prerequisite.find params[:id]
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
    @prerequisite = Prerequisite.find params[:id]
    @prerequisite.destroy

    notice = "Prerequisite #{@prerequisite.prerequisite_number} removed."

    respond_to do |format|
      format.html { redirect_to prerequisites_url, :notice => notice }
    end
  end

  # Permits creating and updating prerequisites.
  def prerequisite_params
    params[:prerequisite].permit :prerequisite_number, :waiver_question
  end
  private :prerequisite_params

end
