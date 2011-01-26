class RunResultsController < ApplicationController
  # GET /run_results
  def index
    @run_results = RunResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /run_results/1
  def show
    @run_result = RunResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /run_results/new
  def new
    @run_result = RunResult.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /run_results/1/edit
  def edit
    @run_result = RunResult.find(params[:id])
  end

  # POST /run_results
  def create
    @run_result = RunResult.new(params[:run_result])

    respond_to do |format|
      if @run_result.save
        flash[:notice] = 'RunResult was successfully created.'
        format.html { redirect_to(@run_result) }
      else
        format.html { render :action => "new" }
      end
    end
  end
    
  # PUT /run_results/1
  def update
    @run_result = RunResult.find(params[:id])

    respond_to do |format|
      if @run_result.update_attributes(params[:run_result])
        flash[:notice] = 'RunResult was successfully updated.'
        format.html { redirect_to(@run_result) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /run_results/1
  def destroy
    @run_result = RunResult.find(params[:id])
    @run_result.destroy

    respond_to do |format|
      format.html { redirect_to(run_results_url) }
    end
  end
end
