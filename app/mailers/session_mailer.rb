class SessionMailer < ApplicationMailer
  include Authpwn::SessionMailer

  def email_verification_subject(token, server_hostname, protocol)
    "Igor e-mail verification"
  end

  def email_verification_from(token, server_hostname, protocol)
    %Q|"Igor staff" <#{SmtpServer.first.user_name}>|
  end

  def reset_password_subject(token, server_hostname, protocol)
    "Igor password reset"
  end

  def reset_password_from(token, server_hostname, protocol)
    %Q|"Igor staff" <#{SmtpServer.first.user_name}>|
  end


  # You shouldn't extend the session mailer, so you can benefit from future
  # features. But, if you must, you can do it here.

  include DynamicSmtpServer

  # TODO(pwnall): This doesn't belong here.
  def team_invite_email(athena, origin_id, team)
    @invitee_name = Profile.find_by_athena_username(athena).name
    @inviter_name = Profile.find_by_user_id(origin_id).name
    @team_name = team.name
    @partition_name = TeamPartition.find_by_id(team.partition_id).name
    email = athena + "@mit.edu"
    subject = "#{team.course.number} Team Invite"
    mail from: "Igor staff <#{SmtpServer.first.user_name}>", to: email,
         subject: subject
  end
end
