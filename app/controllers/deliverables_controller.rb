class DeliverablesController < ApplicationController
  before_filter :authenticated_as_admin

  in_place_edit_for_boolean :deliverable, :published
  in_place_edit_for :deliverable, :filename
  in_place_edit_for :deliverable, :name
  in_place_edit_for :deliverable, :description

  # GET /deliverables/1
  def show
    @deliverable = Deliverable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /deliverables/new
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
      else
        format.html do
          flash[:notice] = 'Deliverable was successfully updated.'
        end
      end
    end
  end


  # POST /deliverables
  def create
    @deliverable = Deliverable.new(params[:deliverable])
    create_update
  end
  
  # PUT /deliverables/1
  def update
    @deliverable = Deliverable.find(params[:id])
    create_update
  end
  
  # DELETE /deliverables/1
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
    end
  end  
end
