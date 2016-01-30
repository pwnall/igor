class SessionMailer < ApplicationMailer
  include Authpwn::SessionMailer

  def email_verification_subject(token, server_hostname, protocol)
    "Igor e-mail verification"
  end

  def email_verification_from(token, server_hostname, protocol)
    nil
  end

  def reset_password_subject(token, server_hostname, protocol)
    "Igor password reset"
  end

  def reset_password_from(token, server_hostname, protocol)
    nil
  end


  # You shouldn't extend the session mailer, so you can benefit from future
  # features. But, if you must, you can do it here.

  # TODO(pwnall): This doesn't belong here.
  def team_invite_email(email, origin_id, team)
    @invitee_name = User.with_email(email).name
    @inviter_name = Profile.find_by_user_id(origin_id).name
    @team_name = team.name
    @partition_name = TeamPartition.find_by_id(team.partition_id).name
    subject = "#{team.course.number} Team Invite"
    mail from: "Igor staff <#{SmtpServer.first.user_name}>", to: email,
         subject: subject
  end
end
