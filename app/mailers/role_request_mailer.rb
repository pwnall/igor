class RoleRequestMailer < ActionMailer::Base
  def decision_email(role_request, was_approved, root_url)
    @role_request = role_request
    @was_approved = was_approved
    @course = role_request.course || Course.main
    @protocol, @host = *root_url.split('://', 2)
    @host.slice!(-1) if @host[-1] == ?/

    hostname = @host.split(':', 2).first
    mail to: role_request.user.email,
         from: decision_from(hostname, @protocol),
         subject: decision_subject(hostname, @protocol)
  end

  def decision_subject(server_hostname, protocol)
    %Q|#{@course.number} staff registration decision|
  end

  def decision_from(server_hostname, protocol)
    %Q|"#{@course.number} staff" <#{Course.main.email}>|
  end

  def notice_email(role_request, root_url)
    @role_request = role_request
    @course = role_request.course || Course.main
    @protocol, @host = *root_url.split('://', 2)
    @host.slice!(-1) if @host[-1] == ?/

    hostname = @host.split(':', 2).first
    mail to: role_request.user.email,
         from: notice_from(hostname, @protocol),
         subject: notice_subject(hostname, @protocol)
  end

  def notice_subject(server_hostname, protocol)
    %Q|#{@course.number} staff approval request|
  end

  def notice_from(server_hostname, protocol)
    %Q|"#{@course.number} staff" <#{Course.main.email}>|
  end
end
