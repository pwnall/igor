#!/usr/bin/ruby
#
# This is a load test for the site's auto-grading feature.
#
# Run the test against an empty installation, using the command below.
#
# URL=http://localhost:3000 COURSE=6.006 STUDENTS=50 ruby
#     test/load/uploading_submissions_test.rb

require 'mechanize'

class LoadTestSession
  def initialize(root_url)
    @root_url = root_url
    @agent = Mechanize.new
    @agent.verify_mode= OpenSSL::SSL::VERIFY_NONE
  end

  # Log in to the site.
  #
  # @return {Boolean} true if the login succeeded, false otherwise
  def log_in(email, password)
    @agent.cookie_jar.clear!
    @agent.get @root_url
    form = @agent.page.form_with(class: 'new_session')

    form['session[email]'] = email
    form['session[password]'] = password

    result_page = form.submit
    result_page.link_with(text: 'Sign out') != nil
  end

  # Fill out and submit the user sign up form.
  #
  # @return {Boolean} true if the sign up succeeded, false otherwise
  def sign_up(email, password)
    @agent.cookie_jar.clear!
    @agent.get File.join(@root_url, '_/users/new')

    form = @agent.page.form_with id: 'new_user'

    form['user[email]'] = email
    form['user[password]'] = password
    form['user[password_confirmation]'] = password
    form['user[profile_attributes][athena_username]'] = 'loadtest'
    form['user[profile_attributes][name]'] = 'Load Test'
    form['user[profile_attributes][nickname]'] = 'Load Test'
    form['user[profile_attributes][university]'] = 'MIT'
    form['user[profile_attributes][department]'] = 'EECS'
    form['user[profile_attributes][year]'] = 'G'

    result_page = form.submit
    !!result_page.root.css('.status-bar').text.index(/log in now/i)
  end

  # Register as a staff member for a class.
  #
  # This assumes that the session belongs to a user that has not registered for
  # the class.
  #
  # @return {Boolean} true if the registration succeeded, false otherwise
  def register_staff(course)
    @agent.get File.join(@root_url, course, 'role_requests/new')
    form = @agent.page.form_with class: 'staff-role-request-form'
    return false if form.nil?
    result_page = form.submit
    !!result_page.root.css('.status-bar').text.
        index(/access requested/i)
  end

  # Approve all pending staff member requests for a class.
  #
  # This assumes that the session belongs to a site admin or course staff.
  #
  # @return {Number?} the number of approved registrations, or nil if approving
  #   failed
  def approve_staff_requests(course)
    @agent.get File.join(@root_url, course, 'role_requests')

    approved_requests = 0
    loop do
      form = @agent.page.form_with(action:
          /^\/#{Regexp.quote course}\/role_requests\/\d+\/approve$/)
      break if form.nil?
      result_page = form.submit
      unless result_page.root.css('.status-bar').text.index(/is now a/i)
        return nil
      end
      approved_requests += 1
    end
    approved_requests
  end

  # Create a course within which all other models will belong.
  #
  # @param {String} course the number of the course
  # @return {Boolean} true if the course was created successfully
  def create_course(course)
    @agent.get File.join(@root_url, '_/courses/new')

    form = @agent.page.form_with class: 'new_course'
    return false unless form

    form['course[number]'] = course
    form['course[title]'] = 'Intro to Algorithms'
    form['course[email]'] = "#{course}-tas@mit.edu"
    form['course[ga_account]'] = 'UA-19600078-2'
    result_page = form.submit
    !!result_page.root.css('.status-bar').text.
        index(/course #{course} created/i)
  end

  # @return {Hash<String, Number>} maps each assignment's name to its ID
  def list_assignments(course)
    @agent.get File.join(@root_url, course, 'assignments.json')
    assignments_json = JSON.parse @agent.page.body

    assignments = {}
    assignments_json.each do |assignment|
      assignments[assignment['name']] = assignment['id']
    end
    assignments
  end

  # Creates an assignment for load testing.
  #
  # To facilitate load testing, the assignment has one deliverable set up with
  # a Docker analyzer, and one metric called "Problem 1".
  #
  # This assumes that the session belongs to a site admin or course staff.
  #
  # @return {Number?} the ID of the created assignment, or nil if creation
  #   failed
  def create_load_test_assignment(course, name, analyzer_path)
    @agent.get File.join(@root_url, course, 'assignments/new')

    form = @agent.page.form_with class: 'new-assignment-form'
    form['assignment[name]'] = name
    tomorrow = Time.now + 24 * 60 * 60
    form['assignment[released_at]'] = tomorrow.strftime('%Y-%m-%dT%H:%M:%S')
    next_week = Time.now + 7 * 24 * 60 * 60
    form['assignment[due_at]'] = next_week.strftime('%Y-%m-%dT%H:%M:%S')
    form['assignment[weight]'] = 1
    result_page = form.submit
    unless result_page.root.css('.status-bar').text.
        index(/assignment created/i)
      return nil
    end
    unless match = /assignments\/(\d+)\/edit$/.match(result_page.uri.to_s)
      return nil
    end
    assignment_id = match[1].to_i

    form = result_page.form_with class: /edit-assignment-form/

    deliverable_param = 'assignment[deliverables_attributes][0]'
    form["#{deliverable_param}[name]"] = 'Fib'
    form["#{deliverable_param}[description]"] = 'Upload'
    form["#{deliverable_param}[analyzer_attributes][map_time_limit]"] = 5
    form["#{deliverable_param}[analyzer_attributes][map_ram_limit]"] = 1024
    form["#{deliverable_param}[analyzer_attributes][map_logs_limit]"] = 1
    form["#{deliverable_param}[analyzer_attributes][reduce_time_limit]"] = 5
    form["#{deliverable_param}[analyzer_attributes][reduce_ram_limit]"] = 1024
    form["#{deliverable_param}[analyzer_attributes][reduce_logs_limit]"] = 10
    form["#{deliverable_param}[analyzer_attributes][auto_grading]"] = 1
    form["#{deliverable_param}[analyzer_attributes][type]"] = 'DockerAnalyzer'

    file_field_name =
        "#{deliverable_param}[analyzer_attributes][db_file_attributes][f]"
    upload_field = Mechanize::Form::FileUpload.new({
        'name' => file_field_name, 'type' => 'file' }, analyzer_path)
    upload_field.file_data = File.read analyzer_path
    upload_field.mime_type = 'application/zip'
    form.file_uploads << upload_field

    metric_param = 'assignment[metrics_attributes][0]'
    form["#{metric_param}[name]"] = 'Problem 1'
    form["#{metric_param}[max_score]"] = 10
    form["#{metric_param}[weight]"] = 1

    result_page = form.submit
    unless result_page.root.css('.status-bar').text.
        index(/assignment updated/i)
      return nil
    end

    assignment_id
  end

  # Releases an assignment to students.
  #
  # @return {Boolean} true if the assignment was released successfully
  def release_assignment(course, assignment_id)
    @agent.get File.join(@root_url, course, 'assignments', assignment_id.to_s,
                         'dashboard')
    form = @agent.page.form_with class: 'assignment-release-form'
    return false unless form

    result_page = form.submit
    !!result_page.root.css('.status-bar').text.
        index(/assignment unlocked/i)
  end

  # Register for a class.
  #
  # This assumes that the session belongs to a user that has not registered for
  # the class.
  #
  # @return {Boolean} true if the registration succeeded, false otherwise
  def register_student(course)
    @agent.get File.join(@root_url, course, 'registrations/new')

    form = @agent.page.form_with id: 'new_registration'
    form.checkbox_with(name: 'registration[for_credit]').check
    result_page = form.submit
    !!result_page.root.css('.status-bar').text.
        index(/you are now registered/i)
  end


  # Sets up a submission form.
  #
  # @return {Mechanize::Form} a submission form, primed and ready to be
  #   sent to the server
  def upload_submission_form(course, assignment_id, file_data)
    @agent.get File.join(@root_url, course, 'assignments', assignment_id.to_s)

    form = @agent.page.form_with class: 'new-submission-form'
    upload_field = form.file_upload_with(
        name: 'submission[db_file_attributes][f]')

    upload_field.file_name = 'file.py'
    upload_field.mime_type = 'text/x-python-script'
    upload_field.file_data = file_data
    form
  end

  # Sends a submission form to the server.
  #
  # @return {Boolean} true if the assignment was submitted
  def upload_submission(form)
    result_page = form.submit
    !!result_page.root.css('.status-bar').text.
        index(/uploaded/i)
  end

  # Retrieves the assignment's page.
  #
  # @return {Boolean} true if the fetching succeeded, false otherwise
  def view_assignment_page(course, assignment_id)
    @agent.get File.join(@root_url, course, 'assignments', assignment_id.to_s)
    !!@agent.page.form_with(class: 'new-submission-form')
  rescue Mechanize::ResponseCodeError
    false
  end

  # Retrieves a course's page.
  #
  # @return {Boolean} true if the fetching succeeded, false otherwise
  def view_course_home(course)
    @agent.get File.join(@root_url, course)
    !!@agent.page.root.css('.course-number').text.index(course)
  rescue Mechanize::ResponseCodeError
    false
  end
end

class SubmissionUploadLoadTester
  attr_reader :students

  def initialize(root_url, course, students)
    @root_url = root_url
    @course = course
    @students = students
    @assignment_id = nil

    submission_path = File.expand_path(
        '../../fixtures/files/submission/good_fib.py', __FILE__)
    @submission_data = File.read submission_path

    @admin_session = LoadTestSession.new @root_url
    @staff_session = LoadTestSession.new @root_url
    @student_sessions = (1..@students).map do |i|
      LoadTestSession.new @root_url
    end
    @student_forms = Array.new @students
  end

  # Creates the infrastructure for the load test.
  def setup
    unless @admin_session.log_in('admin@mit.edu', 'mit')
      unless @admin_session.sign_up('admin@mit.edu', 'mit')
        raise 'Failed to sign up admin@mit.edu'
      end
      unless @admin_session.log_in('admin@mit.edu', 'mit')
        raise 'Failed to log in after signing up admin@mit.edu'
      end
    end
    unless @admin_session.view_course_home(@course)
      unless @admin_session.create_course(@course)
        raise 'Failed to create course'
      end
    end

    @staff_session = LoadTestSession.new @root_url
    unless @staff_session.log_in('staff@mit.edu', 'mit')
      unless @staff_session.sign_up('staff@mit.edu', 'mit')
        raise 'Failed to sign up staff@mit.edu'
      end
      unless @staff_session.log_in('staff@mit.edu', 'mit')
        raise 'Failed to log in after signing up staff@mit.edu'
      end
      unless @staff_session.register_staff(@course)
        raise 'Failed to register staff@mit.edu as course staff'
      end
      unless @admin_session.approve_staff_requests(@course) >= 1
        raise 'Failed to approve staff@mit.edu as course staff'
      end
    end

    assignment_id = nil
    unless assignments = @staff_session.list_assignments(@course)
      raise 'Failed to list course assignments'
    end
    unless assignment_id = assignments['Load Lab']
      analyzer_path = File.expand_path(
          '../../fixtures/files/analyzer/fib_small.zip', __FILE__)
      unless assignment_id = @staff_session.create_load_test_assignment(
          @course, 'Load Lab', analyzer_path)
        raise 'Failed to create load test assignment'
      end
      unless @staff_session.release_assignment(@course, assignment_id)
        raise 'Failed to release load test assignment'
      end
    end

    @assignment_id = assignment_id
  end

  # Prepares a student for the submission test.
  def arm_student(serial)
    student_session = @student_sessions[serial - 1]
    unless student_session.log_in("student#{serial}@mit.edu", 'mit')
      unless student_session.sign_up("student#{serial}@mit.edu", 'mit')
        raise "Failed to sign up student#{serial}@mit.edu"
      end
      unless student_session.log_in("student#{serial}@mit.edu", 'mit')
        raise "Failed to log in after signing up student#{serial}@mit.edu"
      end
      unless student_session.register_student(@course)
        raise "Failed to register student#{serial}@mit.edu in the class"
      end
    end

    @student_forms[serial - 1] = student_session.upload_submission_form(
        '6.006', @assignment_id, @submission_data)
  end

  # Uploads a student's submission to the server.
  #
  # This is the core of the load test.
  def fire_student(serial)
    student_session = @student_sessions[serial - 1]
    submission_form = @student_forms[serial - 1]
    unless student_session.upload_submission(submission_form)
      raise "Failed to upload submission for student#{serial}@mit.edu"
    end
  end

  # Simulates a student refreshing course pages.
  def refresh_student(serial)
    student_session = @student_sessions[serial - 1]
    unless student_session.view_course_home(@course)
      raise "Failed to refresh course home for student#{serial}@mit.edu"
    end
    unless student_session.view_assignment_page(@course, @assignment_id)
      raise "Failed to refresh assignment page for student#{serial}@mit.edu"
    end
  end
end

base_url = ENV['URL'] || 'http://localhost:3000'
course = ENV['COURSE'] || '6.006'
students = (ENV['STUDENTS'] || '3').to_i
tester = SubmissionUploadLoadTester.new base_url, course, students
tester.setup
Thread.abort_on_exception = true

threads = (1..(tester.students)).map do |i|
  Thread.new(i) { |serial| tester.arm_student serial }
end
threads.each(&:join)

threads = (1..(tester.students)).map do |i|
  Thread.new(i) { |serial| tester.fire_student serial }
end
threads.each(&:join)

threads = (1..(tester.students)).map do |i|
  Thread.new(i) { |serial| tester.refresh_student serial }
end
threads.each(&:join)
