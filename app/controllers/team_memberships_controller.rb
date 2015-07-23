class TeamMembershipsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_course_editor

  # POST /6.006/team_memberships
  def create
    @team_membership = TeamMembership.new team_membership_new_params
    @user = User.find_first_by_query!(params[:query])
    @team_membership.user = @user
    respond_to do |format|
      if @team_membership.save
        format.html do
          redirect_to team_partition_url(@team_membership.partition,
              course_id: @team_membership.course), notice:
              "#{@user.name} added to #{@team_membership.team.name}"
        end
      else
        format.html do
          redirect_to team_partition_url(@team_membership.partition,
              course_id: @team_membership.course), alert:
              "#{@user.name} already belongs to a team in #{@team_membership.partition.name}"
        end
      end
    end
  end

  # DELETE /6.006/team_memberships/1
  def destroy
    @team_membership = current_course.team_memberships.find params[:id]
    @team_membership.destroy

    respond_to do |format|
      format.html do
        redirect_to team_partition_url(@team_membership.partition,
            course_id: @team_membership.course), notice:
            "#{@team_membership.user.name} removed from #{@team_membership.team.name}"
      end
    end
  end

  # Permit updating and creating teams.
  def team_membership_new_params
    params.require(:team_membership).permit :team_id
  end
  private :team_membership_new_params
end
