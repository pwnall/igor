class RunResultsController < ApplicationController
  # GET /run_results
  # GET /run_results.xml
  def index
    @run_results = RunResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @run_results }
    end
  end

  # GET /run_results/1
  # GET /run_results/1.xml
  def show
    @run_result = RunResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @run_result }
    end
  end

  # GET /run_results/new
  # GET /run_results/new.xml
  def new
    @run_result = RunResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @run_result }
    end
  end

  # GET /run_results/1/edit
  def edit
    @run_result = RunResult.find(params[:id])
  end

  # POST /run_results
  # POST /run_results.xml
  def create
    @run_result = RunResult.new(params[:run_result])

    respond_to do |format|
      if @run_result.save
        flash[:notice] = 'RunResult was successfully created.'
        format.html { redirect_to(@run_result) }
        format.xml  { render :xml => @run_result, :status => :created, :location => @run_result }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @run_result.errors, :status => :unprocessable_entity }
      end
    end
  end
    
  # PUT /run_results/1
  # PUT /run_results/1.xml
  def update
    @run_result = RunResult.find(params[:id])

    respond_to do |format|
      if @run_result.update_attributes(params[:run_result])
        flash[:notice] = 'RunResult was successfully updated.'
        format.html { redirect_to(@run_result) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @run_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /run_results/1
  # DELETE /run_results/1.xml
  def destroy
    @run_result = RunResult.find(params[:id])
    @run_result.destroy

    respond_to do |format|
      format.html { redirect_to(run_results_url) }
      format.xml  { head :ok }
    end
  end
end
