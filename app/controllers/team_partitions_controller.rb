class TeamPartitionsController < ApplicationController
  before_filter :authenticated_as_admin
  
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
    @team = Team.new :partition => @team_partition 

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team_partition }
    end
  end

  # GET /team_partitions/new
  # GET /team_partitions/new.xml
  def new
    @team_partition = TeamPartition.new
    new_edit
  end

  # GET /team_partitions/1/edit
  def edit
    @team_partition = TeamPartition.find(params[:id])
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @team_partition }
    end
  end
  private :new_edit

  # POST /team_partitions
  # POST /team_partitions.xml
  def create
    @team_partition = TeamPartition.new(params[:team_partition])
    create_update
  end

  # PUT /team_partitions/1
  # PUT /team_partitions/1.xml
  def update
    @team_partition = TeamPartition.find(params[:id])
    create_update
  end
  
  def create_update
    @is_new_record = @team_partition.new_record?
    if @is_new_record
      success = @team_partition.save
    else
      success = @team_partition.update_attributes(params[:team_partition])
    end
    
    respond_to do |format|
      if success
        if @is_new_record && @team_partition.automated?
          team_size = params[:optimal_size].to_i
          team_size = 3 if team_size == 0
          @team_partition.auto_assign_users team_size
        end

        flash[:notice] = "Team partition #{@team_partition.name} successfully #{@is_new_record ? 'created' : 'updated'}."
        format.html { redirect_to team_partitions_path }
        format.xml do
          if is_new_record
            render :xml => @recitation_section, :status => :created, :location => @recitation_section
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @team_partition.errors, :status => :unprocessable_entity }
      end
    end
  end
  private :create_update

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
