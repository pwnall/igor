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

  def recitation_assignment_email(email, recitation_assignments, 
                                  reverted_matching, students,
                                  root_url)
    @recitation_assignments = recitation_assignments
    @reverted_matching = reverted_matching
    @students = students
    @email = email
    @protocol, @host = *root_url.split('://', 2)
    @host.slice! -1 if @host[-1] == ?/

    hostname = @host.split(':', 2).first
    mail :to => email, 
         :from => recitation_assignment_from(hostname, @protocol),
         :subject => recitation_assignment_from(hostname, @protocol)

  end

  def recitation_assignment_subject(server_hostname, protocol)
    %Q|"#{Course.main.number} recitation assignments"|
  end

  def recitation_assignment_from(server_hostname, protocol)
    %Q|"#{Course.main.number} staff" <#{Course.main.email}>|
  end

  # Add your extensions to the SessionMailer class here.  
end
