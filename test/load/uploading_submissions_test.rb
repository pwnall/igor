require 'mechanize'
require 'faker'

class SubmissionUploadLoadTester
  def initialize(admin_username, admin_password)
    @agent = Mechanize.new
    @admin_username = admin_username
    @admin_password = admin_password
    register_user nil, @admin_username, @admin_password
  end

  # Fill out and submit the registration form.
  #
  # @param [Integer] id a value appended to the user's username to ensure
  #     uniqueness
  # @param [String] username the new user's username
  # @param [String] password the new user's password
  # @return [Array<String>] the username and password of the new user
  def register_user(id, username, password)
    @agent.cookie_jar.clear!
    @agent.get 'http://localhost:3000/'
    @agent.page.form_with(action: '/_/users/new') { |f| f.submit }
    @agent.page.form_with(id: 'new_user') do |f|
      name = Faker::Name.name
      username ||= Faker::Internet.user_name "#{name} #{id}".rstrip
      password ||= Faker::Internet.password
      f['user[email]'] = username + '@mit.edu'
      f['user[password]'] = password
      f['user[password_confirmation]'] = password
      f['user[profile_attributes][athena_username]'] = username
      f['user[profile_attributes][name]'] = name
      f['user[profile_attributes][nickname]'] = name.split[0]
      f['user[profile_attributes][university]'] = Faker::University.name
      f['user[profile_attributes][department]'] = 'EECS'
      f['user[profile_attributes][year]'] = 'G'
      f.submit
    end
    [username, password]
  end
  private :register_user

  # Register as a student in the course.
  def register_student(id: nil, username: nil, password: nil)
    username, password = register_user id, username, password
    log_in username, password
    @agent.page.link_with(href: '/6.006/registrations/new').click
    @agent.page.form_with(id: 'new_registration') do |f|
      f.checkbox_with(name: 'registration[for_credit]').check
      f.submit
    end
    [username, password]
  end

  # Register and request to be the course instructor.
  def register_staff(id: nil, username: nil, password: nil)
    username, password = register_user id, username, password
    log_in username, password
    @agent.page.link_with(href: '/6.006/role_requests/new').click
    @agent.page.forms_with(id: 'new_role_request').each do |f|
      f.submit if f.has_value? 'staff'
    end

    log_in @admin_username, @admin_password
    @agent.get 'http://localhost:3000/6.006/role_requests'
    @agent.page.form_with(action: '/6.006/role_requests/1/approve') do |f|
      f.submit
    end
  end

  # Log in to the site.
  def log_in(username, password)
    @agent.cookie_jar.clear!
    @agent.get 'http://localhost:3000/'
    @agent.page.form_with(class: 'new_session') do |f|
      f['session[email]'] = "#{username}@mit.edu"
      f['session[password]'] = password
      f.submit
    end
  end

  def create_assignment_with_deliverable
    log_in @admin_username, @admin_password
    @agent.get '/6.006/assignments/new'
    @agent.page.form_with(class: 'new_assignment') do |f|
      f['assignment[name]'] = 'Lab 1'
      f['assignment[due_at(2i)]'] = (Time.now.month + 1) % 12
      f['assignment[weight]'] = 10
      f.submit
    end

    @agent.page.form_with(class: 'edit_assignment') do |f|
      deliverable_param = 'assignment[deliverables_attributes][0]'
      f["#{deliverable_param}[name]"] = 'Fib'
      f["#{deliverable_param}[file_ext]"] = 'py'
      f["#{deliverable_param}[description]"] = 'Upload'
      f["#{deliverable_param}[analyzer_attributes][map_time_limit]"] = 5
      f["#{deliverable_param}[analyzer_attributes][map_ram_limit]"] = 1024
      f["#{deliverable_param}[analyzer_attributes][reduce_time_limit]"] = 5
      f["#{deliverable_param}[analyzer_attributes][reduce_ram_limit]"] = 1024
      f["#{deliverable_param}[analyzer_attributes][auto_grading]"] = 1
      f["#{deliverable_param}[analyzer_attributes][type]"] = 'DockerAnalyzer'

      file_name = File.expand_path(
          '../../fixtures/files/analyzer/fib_small.zip', __FILE__)
      file_field_name =
          "#{deliverable_param}[analyzer_attributes][db_file_attributes][f]"
      upload_field = Mechanize::Form::FileUpload.new({
          'name' => file_field_name, 'type' => 'file' }, file_name)
      f.file_uploads << upload_field

      metric_param = 'assignment[metrics_attributes][0]'
      f["#{metric_param}[name]"] = 'Problem 1'
      f["#{metric_param}[max_score]"] = 10
      f["#{metric_param}[weight]"] = 1
      f.submit
    end

    @agent.get 'http://localhost:3000/6.006/assignments/1/dashboard'
    form_attrs = { action: '/6.006/assignments/1', method: /\APOST\z/i }
    @agent.page.form_with(form_attrs) { |f| f.submit }
  end

  def upload_submission
    @agent.get 'http://localhost:3000/6.006/assignments/1'
    form_attrs = { action: '/6.006/submissions', method: /\APOST\z/i }
    @agent.page.form_with(form_attrs) do |f|
      file_name = File.expand_path(
          '../../fixtures/files/submission/good_fib.py', __FILE__)
      file_field_name = 'submission[db_file_attributes][f]'
      f.file_upload_with(name: file_field_name).file_name = file_name
      f.submit
    end
  end
end

tester = SubmissionUploadLoadTester.new 'spark008', 'asdf'

# Create a staff member (to be the assignment's author).
tester.register_staff

# Create an assignment.
tester.create_assignment_with_deliverable

# Create 10 students.
student_credentials = []
10.times do |i|
  student_credentials << tester.register_student(id: i)
end
p student_credentials

# Upload 5 submissions per student.
student_credentials.each do |username, password|
  tester.log_in username, password
  5.times { |i| tester.upload_submission }
end
