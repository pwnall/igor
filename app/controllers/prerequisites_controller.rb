class PrerequisitesController < ApplicationController  
  before_filter :authenticated_as_admin, :except => [:new, :index, :show] 
  
  [:course_number, :waiver_question].each do |field|
    in_place_edit_for :prerequisite, field
  end
  
  # GET /prerequisites
  # GET /prerequisites.xml
  def index
    @prerequisites = Prerequisite.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @prerequisites }
    end
  end

  # GET /prerequisites/1
  # GET /prerequisites/1.xml
  def show
    @prerequisite = Prerequisite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @prerequisite }
    end
  end

  # GET /prerequisites/new
  # GET /prerequisites/new.xml
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
      format.xml  { render :xml => @prerequisite }
    end
  end
  private :new_edit

  # POST /prerequisites
  # POST /prerequisites.xml
  def create
    @prerequisite = Prerequisite.new(params[:prerequisite])
    create_update
  end

  # PUT /prerequisites/1
  # PUT /prerequisites/1.xml
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
        format.xml do
          if is_new_record
            render :xml => @prerequisite, :status => :created,
                   :location => @prerequisite
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml do
          render :xml => @prerequisite.errors, :status => :unprocessable_entity
        end
      end
    end    
  end
  private :create_update
  

  # DELETE /prerequisites/1
  # DELETE /prerequisites/1.xml
  def destroy
    @prerequisite = Prerequisite.find(params[:id])
    @prerequisite.destroy

    respond_to do |format|
      format.html { redirect_to(prerequisites_url) }
      format.xml  { head :ok }
    end
  end
end
