class AssignmentMetricsController < ApplicationController
  before_filter :authenticated_as_admin
  
  # GET /assignment_metrics/new
  def new
    @assignment_metric = AssignmentMetric.new
    new_edit
  end

  # GET /assignment_metrics/1/edit
  def edit
    @assignment_metric = AssignmentMetric.find(params[:id])
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
    end
  end
  private :new_edit

  # POST /assignment_metrics
  def create
    @assignment_metric = AssignmentMetric.new(params[:assignment_metric])
    create_update
  end

  # PUT /assignment_metrics/1
  def update
    @assignment_metric = AssignmentMetric.find(params[:id])
    create_update
  end
  
  def create_update
    @is_new_record = @assignment_metric.new_record?
    if @is_new_record
      success = @assignment_metric.save
    else
      success = @assignment_metric.update_attributes(params[:assignment_metric])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Assignment metric successfully #{@is_new_record ? 'submitted' : 'updated'}."
        format.html { redirect_to(:controller => :assignment_metrics, :action => :index) }
      else
        format.html { render :action => :new_edit }
      end
    end    
  end
  private :create_update
  
  # DELETE /assignment_metrics/1
  def destroy
    @assignment_metric = AssignmentMetric.find(params[:id])
    @assignment_metric.destroy

    respond_to do |format|
      format.html { redirect_to(assignment_metrics_url) }
    end
  end
end
