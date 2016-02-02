class TeamPartitionsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_course_editor
  before_action :set_team_partition, only: [:show, :edit, :update, :destroy,
      :lock, :unlock, :issues]

  # GET /6.006/team_partitions
  def index
    @team_partitions = current_course.team_partitions

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /6.006/team_partitions/1
  def show
    @team = Team.new partition: @team_partition

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /6.006/team_partitions/new
  def new
    @team_partition = TeamPartition.new course: current_course
    new_edit
  end

  # GET /6.006/team_partitions/1/edit
  def edit
    new_edit
  end

  def new_edit
    respond_to do |format|
      format.html { render :new_edit }
    end
  end
  private :new_edit

  # POST /6.006/team_partitions
  def create
    @team_partition = TeamPartition.new team_params
    @team_partition.course = current_course
    create_update
  end

  # PUT /6.006/team_partitions/1
  def update
    create_update
  end

  def create_update
    @is_new_record = @team_partition.new_record?
    if @is_new_record
      success = @team_partition.save
    else
      success = @team_partition.update team_params
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
              @team_partition.populate_from(
                current_course.team_partitions.
                find(params[:clone_partition_id]))
            end
          end
        end

        flash[:notice] =
        format.html do
          redirect_to team_partitions_url(course_id: @team_partition.course),
            notice: "Team partition #{@team_partition.name} successfully #{@is_new_record ? 'created' : 'updated'}."
        end
      else
        format.html { render :new_edit }
      end
    end
  end
  private :create_update

  # DELETE /6.006/team_partitions/1
  def destroy
    @team_partition.destroy

    respond_to do |format|
      format.html do
        redirect_to team_partitions_url(course_id: @team_partition.course)
      end
    end
  end

  # PATCH /6.006/team_partitions/1/unlock
  def unlock
    @team_partition.editable = true
    @team_partition.save

    respond_to do |format|
      format.html do
        redirect_to team_partition_url(@team_partition,
                                       course_id: @team_partition.course_id)
      end
    end
  end

  # PATCH /6.006/team_partitions/1/lock
  def lock
    @team_partition.editable = false
    @team_partition.save

    respond_to do |format|
      format.html do
        redirect_to team_partition_url(@team_partition,
                                       course_id: @team_partition.course_id)
      end
    end
  end

  # GET /6.006/team_partitions/1/issues
  def issues
    unless @team_partition.min_size.nil?
      @too_small = @team_partition.teams.select do |team|
        team.size < @team_partition.min_size
      end
    end
    unless @team_partition.max_size.nil?
      @too_large = @team_partition.teams.select do |team|
        team.size > @team_partition.max_size
      end
    end
    @not_assigned = @team_partition.course.students -
                    @team_partition.assigned_users

    respond_to do |format|
      format.html
    end
  end

  def set_team_partition
    @team_partition = current_course.team_partitions.find params[:id]
  end
  private :set_team_partition

  # Permit updating and creating team partitions.
  def team_params
    params.require(:team_partition).permit(:name, :automated, :min_size, :max_size, :released)
  end
  private :team_params
end
