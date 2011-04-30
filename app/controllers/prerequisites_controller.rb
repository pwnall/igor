class PrerequisitesController < ApplicationController  
  before_filter :authenticated_as_admin, :except => [:new, :index, :show] 
  
  # GET /prerequisites
  def index
    @prerequisites = Prerequisite.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /prerequisites/1
  def show
    @prerequisite = Prerequisite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /prerequisites/new
  def new
    @prerequisite = Prerequisite.new
    new_edit
  end

  # GET /prerequisites/1/edit
  def edit
    @prerequisite = Prerequisite.find(params[:id])
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
    end
  end
  private :new_edit

  # POST /prerequisites
  def create
    @prerequisite = Prerequisite.new(params[:prerequisite])
    create_update
  end

  # PUT /prerequisites/1
  def update
    @prerequisite = Prerequisite.find(params[:id])
    create_update
  end
  
  def create_update
    @is_new_record = @prerequisite.new_record?
    if @is_new_record
      success = @prerequisite.save
    else
      success = @prerequisite.update_attributes(params[:prerequisite])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = 'Prerequisite successfully ' +
                         (@is_new_record ? 'submitted.' : 'updated.')
        format.html { redirect_to :action => :index }
      else
        format.html { render :action => :new_edit }
      end
    end    
  end
  private :create_update
  

  # DELETE /prerequisites/1
  def destroy
    @prerequisite = Prerequisite.find(params[:id])
    @prerequisite.destroy

    respond_to do |format|
      format.html { redirect_to(prerequisites_url) }
    end
  end
end
