class TeamsStudentController < ApplicationController
  before_filter :authenticated_as_user

  def show
    @team_memberships = TeamMembership.where(:user_id => current_user.id)    
    @partitions = TeamPartition.find(:all)
    
    @partitions_without_team_membership = TeamPartition.find(:all)
    @team_memberships.each do |team_membership|
      team = Team.find_by_id( team_membership.team_id )
      @partitions_without_team_membership = 
        @partitions_without_team_membership.reject { |r| (r.id == team.partition_id) }
    end
  end

  # Lets a user leave a team. Team destroyed if now empty.
  def leave_team
    team = Team.find_by_id(params[:id])
    partition = TeamPartition.find_by_id(team.partition_id)
    if partition.editable
      team_membership = TeamMembership.where(:user_id => current_user.id, :team_id => team.id).first
      team_membership.destroy
      ## If the Team is now empty...
      if TeamMembership.where(:team_id => team.id) == nil
        team.destroy
      end
      flash[:notice] = "You have been removed from that team."
    else
      flash[:notice] = "That team is not editable."
    end
    redirect_to teams_student_path
  end

  def create_team
    partition = TeamPartition.find_by_id(params[:id])
    if partition && partition.editable
      # Ensure that the student doesn't already have a Team for this partition
      TeamMembership.where(:user_id => current_user.id).each do |tm|
        if tm.partition_id == partition.id
          flash[:notice] = "You already have a team for " + partition.name.to_s + "."
          redirect_to teams_student_path and return
        end
      end
      # Now we can create a team and add them to it.
      
    end
  end

end
