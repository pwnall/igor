class RoleRequestMailer < ApplicationMailer
  def decision_email(role_request, was_approved, root_url)
    @role_request = role_request
    @was_approved = was_approved
    @protocol, @host = *root_url.split('://', 2)
    @host.slice!(-1) if @host[-1] == ?/

    hostname = @host.split(':', 2).first
    mail to: role_request.user.email,
         from: decision_from(hostname, @protocol),
         subject: decision_subject(hostname, @protocol)
  end

  def decision_subject(server_hostname, protocol)
    access_type = (@role_request.name == 'staff') ? 'instructor' : 'grader'
    if @role_request.course
      number  = @role_request.course.number
    else
      number = 'Site'
    end
    %Q|#{number} #{access_type} access request decision|
  end

  def decision_from(server_hostname, protocol)
    if @role_request.course
      course = @role_request.course
      %Q|"#{course.number} staff" <#{course.email}>|
    else
      'Site staff'
    end
  end

  def notice_email(role_request, root_url)
    @role_request = role_request
    @protocol, @host = *root_url.split('://', 2)
    @host.slice!(-1) if @host[-1] == ?/

    hostname = @host.split(':', 2).first
    mail to: @role_request.course.email,
         from: notice_from(hostname, @protocol),
         subject: notice_subject(hostname, @protocol)
  end

  def notice_subject(server_hostname, protocol)
    access_type = @role_request.name == 'staff' ? 'instructor' : 'grader'
    %Q|#{@role_request.course.number} #{access_type} access request|
  end

  def notice_from(server_hostname, protocol)
    %Q|"#{@role_request.course.number} staff" <#{@role_request.course.email}>|
  end

  include DynamicSmtpServer
end
