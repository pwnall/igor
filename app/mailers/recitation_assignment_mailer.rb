class RecitationAssignmentMailer < ActionMailer::Base
  def recitation_assignment_email(email, recitation_partition, root_url)
    @recitation_partition = recitation_partition
    @course = Course.main
    @email = email
    @protocol, @host = *root_url.split('://', 2)
    @host.slice!(-1) if @host[-1] == ?/

    hostname = @host.split(':', 2).first
    mail :to => email,
         :from => recitation_assignment_from(hostname, @protocol),
         :subject => recitation_assignment_subject(hostname, @protocol)

  end

  def recitation_assignment_subject(server_hostname, protocol)
    %Q|#{Course.main.number} recitation assignment proposal|
  end

  def recitation_assignment_from(server_hostname, protocol)
    %Q|"#{Course.main.number} staff" <#{Course.main.email}>|
  end
end
