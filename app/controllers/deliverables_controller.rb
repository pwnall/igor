class DeliverablesController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:xhr_description]
  before_filter :authenticated_as_user, :only => [:xhr_description]

  # GET /deliverables/1
  # GET /deliverables/1.xml
  def show
    @deliverable = Deliverable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deliverable }
    end
  end

  # GET /deliverables/new
  # GET /deliverables/new.xml
  def new
    @deliverable = Deliverable.new
    @deliverable.assignment = Assignment.find(params[:assignment_id]) 
    new_edit
  end

  # GET /deliverables/1/edit
  def edit
    @deliverable = Deliverable.find(params[:id])
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.js   { render :action => 'new_edit' } # new_edit.js.rjs 
      format.xml  { render :xml => @deliverable }
    end    
  end
  
  def create_update
    @new_record = @deliverable.new_record?
    @div_id = @new_record ? params[:div_id] : @deliverable.id
    
    @success = @new_record ? @deliverable.save : @deliverable.update_attributes(params[:deliverable])
    respond_to do |format|
      format.js do
        render :action => 'create_update'          
      end
      if @success
        format.html do
          flash[:notice] = 'Deliverable was successfully created.'
        end
        if @new_record then format.xml { render :xml => @deliverable, :status => :created, :location => @deliverable }          
        else format.xml { head :ok } end
      else
        format.html do
          flash[:notice] = 'Deliverable was successfully updated.'
        end
        format.xml { render :xml => @deliverable.errors, :status => :unprocessable_entity }        
      end
    end
  end


  # POST /deliverables
  # POST /deliverables.xml
  def create
    @deliverable = Deliverable.new(params[:deliverable])
    create_update
  end
  
  # PUT /deliverables/1
  # PUT /deliverables/1.xml
  def update
    @deliverable = Deliverable.find(params[:id])
    create_update
  end
  
  # DELETE /deliverables/1
  # DELETE /deliverables/1.xml
  def destroy
    @deliverable = Deliverable.find(params[:id])
    @deliverable.destroy

    respond_to do |format|
      format.html { redirect_to(deliverables_url) }
      format.js do
        render :update do |page|
          add_site_status page, "Deliverable #{@deliverable.name} destroyed", true
          page.visual_effect :fade, "deliverable_row_#{@deliverable.id}"
        end
      end
      format.xml  { head :ok }
    end
  end
  
  # called via XHR to get the description
  def xhr_description
    @deliverable = Deliverable.find(:first, :conditions => {:id => params[:deliverable_id]})
    if @deliverable.nil?
      dtext = 'After you select a deliverable, I might give you a description of the file you should submit.'
    else
      dtext = @deliverable.description
      if @deliverable.assignment.deadline <= Time.now
        dtext += '<br /><span style="font-weight: bold">LATE SUBMISSION</span>'
      end
    end
    render :text => dtext
  end
end
