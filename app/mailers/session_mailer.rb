class SessionMailer < ActionMailer::Base
  include Authpwn::SessionMailer

  def email_verification_subject(token, server_hostname, protocol)
    "#{Course.main.number} e-mail verification"
  end
  
  def email_verification_from(token, server_hostname, protocol)
    %Q|"#{Course.main.number} staff" <#{Course.main.email}>|
  end  

  def reset_password_subject(token, server_hostname, protocol)
    "#{Course.main.number} password reset"
  end
  
  def reset_password_from(token, server_hostname, protocol)
    %Q|"#{Course.main.number} staff" <#{Course.main.email}>|
  end

  # Add your extensions to the SessionMailer class here.  
  def team_invite_email(athena, origin_id, team_id)
    @invitee_name = Profile.find_by_athena_username(athena).name
    @inviter_name = Profile.find_by_user_id(origin_id).name
    @team_name = Team.find_by_id(team_id).name
    @partition_name = TeamPartition.find_by_id(Team.find_by_id(team_id).partition_id).name
    email = athena + "@mit.edu"
    subj = "#{Course.main.number}: Team Invite"
    mail(:from => "#{Course.main.number} staff <#{Course.main.email}>", :to => email, :subject => subj)
  end
end
