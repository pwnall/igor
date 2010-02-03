class AssignmentMetricsController < ApplicationController
  before_filter :authenticated_as_admin
  
  in_place_edit_for_boolean :assignment_metric, :published
  [:name, :max_score, :weight, :assignment_id].each { |field| in_place_edit_for :assignment_metric, field }
  
  # GET /assignment_metrics
  # GET /assignment_metrics.xml
  def index
    @assignments = Assignment.find(:all)
    @assignment_metrics = AssignmentMetric.find(:all, :include => :assignment)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assignment_metrics }
    end
  end

  # GET /assignment_metrics/1
  # GET /assignment_metrics/1.xml
  def show
    @assignment_metric = AssignmentMetric.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assignment_metric }
    end
  end

  # GET /assignment_metrics/new
  # GET /assignment_metrics/new.xml
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
      format.xml  { render :xml => @assignment_metric }
    end
  end
  private :new_edit

  # POST /assignment_metrics
  # POST /assignment_metrics.xml
  def create
    @assignment_metric = AssignmentMetric.new(params[:assignment_metric])
    create_update
  end

  # PUT /assignment_metrics/1
  # PUT /assignment_metrics/1.xml
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
        format.xml do
          if is_new_record
            render :xml => @assignment_metric, :status => :created, :location => @assignment_metric
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @assignment_metric.errors, :status => :unprocessable_entity }
      end
    end    
  end
  private :create_update
  
  # POST /assignment_metrics/set_published/1?to=true
  def set_published
    @assignment_metric = AssignmentMetric.find(params[:id])
    @assignment_metric.published = params[:to]
    
    respond_to do |format|
      if @assignment_metric.save
        flash[:notice] = "Grades for #{@assignment_metric.name} in #{@assignment_metric.assignment.name} successfully #{@assignment_metric.published ? 'published' : 'un-published'}."
        format.xml { head :ok }
      else
        flash[:error] = "Failed to #{@assignment_metric.published ? 'publish' : 'un-publish'} grades for #{@assignment_metric.name} in #{@assignment_metric.assignment.assignment}."
        format.xml  { render :xml => @assignment_metric.errors, :status => :unprocessable_entity }
      end    
      format.html { redirect_to(:controller => :assignment_metrics, :action => :index) }
    end
  end
  

  # DELETE /assignment_metrics/1
  # DELETE /assignment_metrics/1.xml
  def destroy
    @assignment_metric = AssignmentMetric.find(params[:id])
    @assignment_metric.destroy

    respond_to do |format|
      format.html { redirect_to(assignment_metrics_url) }
      format.xml  { head :ok }
    end
  end
end
