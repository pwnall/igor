class TeamPartitionsController < ApplicationController
  # GET /team_partitions
  # GET /team_partitions.xml
  def index
    @team_partitions = TeamPartition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_partitions }
    end
  end

  # GET /team_partitions/1
  # GET /team_partitions/1.xml
  def show
    @team_partition = TeamPartition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team_partition }
    end
  end

  # GET /team_partitions/new
  # GET /team_partitions/new.xml
  def new
    @team_partition = TeamPartition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team_partition }
    end
  end

  # GET /team_partitions/1/edit
  def edit
    @team_partition = TeamPartition.find(params[:id])
  end

  # POST /team_partitions
  # POST /team_partitions.xml
  def create
    @team_partition = TeamPartition.new(params[:team_partition])

    respond_to do |format|
      if @team_partition.save
        format.html { redirect_to(@team_partition, :notice => 'TeamPartition was successfully created.') }
        format.xml  { render :xml => @team_partition, :status => :created, :location => @team_partition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team_partition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /team_partitions/1
  # PUT /team_partitions/1.xml
  def update
    @team_partition = TeamPartition.find(params[:id])

    respond_to do |format|
      if @team_partition.update_attributes(params[:team_partition])
        format.html { redirect_to(@team_partition, :notice => 'TeamPartition was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team_partition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /team_partitions/1
  # DELETE /team_partitions/1.xml
  def destroy
    @team_partition = TeamPartition.find(params[:id])
    @team_partition.destroy

    respond_to do |format|
      format.html { redirect_to(team_partitions_url) }
      format.xml  { head :ok }
    end
  end
end
