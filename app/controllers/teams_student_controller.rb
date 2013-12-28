class TeamsStudentController < ApplicationController
  before_filter :authenticated_as_user

  def show
    @team_memberships = TeamMembership.where(:user_id => current_user.id)    
    @partitions = TeamPartition.find(:all)
    
    @invitations = Invitation.where(:invitee_id => current_user.id)
    
    @partitions_without_team_membership = TeamPartition.find(:all)
    @team_memberships.each do |team_membership|
      team = Team.find_by_id( team_membership.team_id )
      @partitions_without_team_membership = 
        @partitions_without_team_membership.reject { |r| (r.id == team.partition_id) }
    end
  end

  # Lets a user leave a team. Team destroyed if now empty.
  def leave_team
    team = Team.find_by_id params[:id]
    partition = TeamPartition.find_by_id team.partition_id
    if partition.editable
      team_membership = TeamMembership.where(:user_id => current_user.id, :team_id => team.id).first
      team_membership.destroy
      ## If the Team is now empty...
      if TeamMembership.where(:team_id => team.id).first == nil
        team.destroy
      end
      flash[:notice] = "You have been removed from that team."
    else
      flash[:notice] = "That team is not editable."
    end
    redirect_to teams_student_path
  end

  def create_team
    partition = TeamPartition.find_by_id params[:part_id]
    name_str = "name"+partition.id.to_s
    name = params[name_str]
    if partition && partition.editable
      # Ensure that the student doesn't already have a Team for this partition
      TeamMembership.where(:user_id => current_user.id).each do |tm|
        team_on = Team.find_by_id(tm.team_id)
        if team_on.partition_id === partition.id
          flash[:notice] = "You already have a team for " + partition.name.to_s + "."
          redirect_to teams_student_path and return
        end
      end
      # Now we can create a team and add them to it.
      team = Team.create(:partition_id => partition.id, :name => name)
      team_membership = TeamMembership.create(:team_id => team.id, :user_id => current_user.id)
      flash[:notice] = "You just created team: " + team.name
    end
    redirect_to teams_student_path and return
  end
  
  def invite_member
    ## Validate the athena is one that is in our system.
    prof = Profile.find_by_athena_username params[:athena]
    ## Check that the partition is editable!
    team = Team.find_by_id params[:team_id]
    partition = TeamPartition.find_by_id team.partition_id
    if !partition.editable && (team.size < team.max_size)
      flash[:notice] = "That partition is final, sorry!"
      redirect_to teams_student_path and return
    end
    if !prof.nil?
      flash[:notice] = "An email has been sent to " + params[:athena] + "@mit.edu"
      Invitation.create(:inviter_id => current_user.id, :invitee_id => prof.user_id, :team_id => params[:team_id])
      SessionMailer.team_invite_email(params[:athena], current_user.id, params[:team_id]).deliver
    else
      flash[:notice] = "Sorry, that user appears to not be in this class."
    end
    redirect_to teams_student_path and return
  end

  def accept_invitation
    inv = Invitation.find_by_id params[:invitation_id]
    team = Team.find_by_id inv.team_id
    if team.size >= team.max_size
      flash[:notice] = "Sorry, that team is full."
      redirect_to teams_student_path and return
    end
    tm = TeamMembership.create(:team_id => inv.team_id, :user_id => inv.invitee_id)
    if tm
      flash[:notice] = "Successful team join."
      inv.destroy
    else
      flash[:notice] = "Oops! Looks like something went wrong."
    end
    redirect_to teams_student_path and return
  end
  
  def ignore_invitation
    inv = Invitation.find_by_id params[:invitation_id]
    inv.destroy
    flash[:notice] = "Invitation ignored."
    redirect_to teams_student_path and return
  end
end
