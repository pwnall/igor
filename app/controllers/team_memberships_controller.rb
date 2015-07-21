class TeamMembershipsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_admin

  # POST /team_memberships
  def create
    @team_membership = TeamMembership.new team_membership_new_params
    @user = User.find_first_by_query!(params[:query])
    @team_membership.user = @user
    respond_to do |format|
      if @team_membership.save
        format.html do
          redirect_to @team_membership.team.partition,
                      :notice => "#{@user.name} added to #{@team_membership.team.name}"
        end
      else
        format.html do
          flash[:error] = "#{@user.name} already belongs to a team in #{@team_membership.team.partition.name}"
          redirect_to @team_membership.team.partition
        end
      end
    end
  end

  # DELETE /team_memberships/1
  def destroy
    @team_membership = TeamMembership.find params[:id]
    @team_membership.destroy

    respond_to do |format|
      format.html do
        redirect_to @team_membership.team.partition,
                    :notice => "#{@team_membership.user.name} removed from #{@team_membership.team.name}"
      end
    end
  end

  # Permit updating and creating teams.
  def team_membership_new_params
    params.require(:team_membership).permit :team_id
  end
  private :team_membership_new_params

end
