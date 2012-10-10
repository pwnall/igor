class TeamsController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  def create
    @team = Team.new(params[:team])
    @team_partition = @team.partition

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
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
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
end
