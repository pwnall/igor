class TeamPartitionsController < ApplicationController
  before_action :authenticated_as_admin

  # GET /team_partitions
  def index
    @team_partitions = TeamPartition.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /team_partitions/1
  def show
    @team_partition = TeamPartition.find params[:id]
    @team = Team.new :partition => @team_partition

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /team_partitions/new
  def new
    @team_partition = TeamPartition.new
    new_edit
  end

  # GET /team_partitions/1/edit
  def edit
    @team_partition = TeamPartition.find params[:id]
    new_edit
  end

  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
    end
  end
  private :new_edit

  # POST /team_partitions
  def create
    @team_partition = TeamPartition.new team_params
    create_update
  end

  # PUT /team_partitions/1
  def update
    @team_partition = TeamPartition.find params[:id]
    create_update
  end

  def create_update
    @is_new_record = @team_partition.new_record?
    if @is_new_record
      success = @team_partition.save
    else
      success = @team_partition.update_attributes team_params
    end

    respond_to do |format|
      if success
        if @is_new_record
          if @team_partition.automated?
            team_size = params[:optimal_size].to_i
            team_size = 3 if team_size == 0
            @team_partition.auto_assign_users team_size
          else
            unless params[:clone_partition_id].blank?
              @team_partition.populate_from TeamPartition.find params[:clone_partition_id]
            end
          end
        end

        flash[:notice] = "Team partition #{@team_partition.name} successfully #{@is_new_record ? 'created' : 'updated'}."
        format.html { redirect_to team_partitions_path }
      else
        format.html { render :action => :new_edit }
      end
    end
  end
  private :create_update

  # DELETE /team_partitions/1
  def destroy
    @team_partition = TeamPartition.find(params[:id])
    @team_partition.destroy

    respond_to do |format|
      format.html { redirect_to(team_partitions_url) }
    end
  end

  def unlock
    team_partition = TeamPartition.find(params[:id])
    team_partition.editable = true
    team_partition.save

    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => params[:id] }
    end
  end

  def lock
    team_partition = TeamPartition.find(params[:id])
    team_partition.editable = false
    team_partition.save

    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => params[:id] }
    end
  end

  def view_problem
    id = params[:id]
    part = TeamPartition.find_by_id(id)

    if !part.min_size.nil?
      @toosmall = Team.where(:partition_id => id)
      @toosmall = @toosmall.reject {|t| t.size >= part.min_size }
    end
    if !part.max_size.nil?
      @toobig = Team.where(:partition_id => id)
      @toobig = @toobig.reject {|t| t.size <= part.max_size }
    end

    @nonassigned = User.where(:admin => false)
    @nonassigned = @nonassigned.reject {|t| t.team_in_partition(id) != nil}

    respond_to do |format|
      format.html
    end
  end

  # Permit updating and creating team partitions.
  def team_params
    params.require(:team_partition).permit(:name, :automated, :min_size, :max_size, :published)
  end
  private :team_params

end
