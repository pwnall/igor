class TeamsController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  def create
    @team = Team.new team_params 
    @team_partition = @team.partition

    if !@team_partition.editable
      ## bounce user here.
    end

    respond_to do |format|
      if @team.save
        format.html do
          redirect_to @team.partition,
                      :notice => 'Team was successfully created.'
        end
      else
        format.html { render :action => 'team_partitions/show' }
      end
    end
  end

  # PUT /teams/1
  def update
    @team = Team.find params[:id]

    if !@team_partition.editable
      ## bounce user here.
    end

    respond_to do |format|
      if @team.update_attributes team_params
        format.html { redirect_to(@team, :notice => 'Team was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /teams/1
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to @team.partition }
    end
  end

  private 
    # Permit updating and creating teams.
    def team_params
      params[:team].permit!
      # TODO(mingy): fill in once update_page is fixed
    end 

end
