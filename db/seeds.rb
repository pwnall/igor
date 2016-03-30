# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

include ActionDispatch::TestProcess  # Want fixture_file_upload.

# HACK(pwnall): Docker is slow, so we cache submission results.
class DockerAnalyzer
  alias_method :run_submission_uncached, :run_submission

  def self.cache
    @cache ||= {}
  end

  def run_submission(submission)
    submission_sha = Digest::SHA2.hexdigest submission.db_file.f.file_contents
    cache_key = "#{deliverable.id}-#{submission_sha}"

    return DockerAnalyzer.cache[cache_key] if DockerAnalyzer.cache[cache_key]
    DockerAnalyzer.cache[cache_key] ||= run_submission_uncached(submission)
  end
end


puts 'Started seeding'

# Infrastructure.

SmtpServer.destroy_all
SmtpServer.create! host: 'smtp.gmail.com', port: 587, domain: 'gmail.com',
    user_name: 'igor.dev.mailer@gmail.com',
    password: 'JC0VORvIGIMFwIkrF6dUJA',
    from: '"Igor Dev Mailer" <igor.dev.mailer@gmail.com>',
    auth_kind: 'plain', auto_starttls: true

puts 'Infrastructure created'

# Course.

Course.destroy_all
course = Course.new
course.update! number: '1.337', title: 'Intro to Pwnage',
    email: '1.337-staff@mit.edu', heap_appid: '2171986850',
    email_on_role_requests: true, has_recitations: true, has_surveys: true,
    has_teams: false, section_size: 15

prereq1 = Prerequisite.new prerequisite_number: '6.01',
                           waiver_question: 'Programming experience'
prereq1.course = course
prereq1.save!

prereq2 = Prerequisite.new prerequisite_number: '6.042',
                           waiver_question: 'Math experience'
prereq2.course = course
prereq2.save!

puts 'Course created'

# Site admin.
admin = User.create! email: 'admin@mit.edu', password: 'mit',
    password_confirmation: 'mit', profile_attributes: { name: 'Site Admin',
      nickname: 'admin', university: 'MIT', department: 'EECS', year: 'G'
    }
admin.email_credential.verified = true
admin.save!
Role.create! user: admin, name: 'admin'

puts 'Admin created'

# Students (90 total).

names = File.read('db/seeds/names.txt').split("\n").
    map { |line| line.split('.', 2).last.strip }
depts = File.read('db/seeds/depts.txt').split("\n").
    map { |line| line.split('(', 2).first.strip }

students = []
names[0...90].each_with_index do |name, i|
  first_name = name.split(' ').first
  short_name = (first_name[0] + name.split(' ').last + "_#{i + 1}").downcase
  user = User.create! email: short_name + '@mit.edu',  password: 'mit',
      password_confirmation: 'mit', profile_attributes: { name: name,
        nickname: first_name, university: 'MIT', year: (1 + (i % 4)).to_s,
        department: depts[i % depts.length]
      }
  user.email_credential.verified = true
  user.email_credential.save!
  students << user

  registration = Registration.create! user: user, course: course,
       for_credit: (i % 5 < 4), allows_publishing: (i % 7 < 5)
  registration.prerequisite_answers.create! prerequisite: prereq1,
      took_course: (i % 2 == 0),
      waiver_answer: (i % 2 == 0) ? nil :
                     'Silver medal at IOI 2011... bitches'
  registration.prerequisite_answers.create! prerequisite: prereq2,
      took_course: (i % 4 < 2),
      waiver_answer: (i % 4 < 2) ? nil :
                     'Bronze medal at IMO 2011, A+ in 18.something'
end

puts 'Students created'

# Staff (10 staff, 20 graders).

staff = []
graders = []
names[90..-1].each_with_index do |name, i|
  first_name = name.split(' ').first
  short_name = (first_name[0] + name.split(' ').last + "_#{i + 1}").downcase
  user = User.create! email: short_name + '@mit.edu', password: 'mit',
      password_confirmation: 'mit', profile_attributes: { name: name,
        nickname: first_name, university: 'MIT', year: (1 + (i % 4)).to_s,
        department: depts[i % depts.length]
      }
  user.email_credential.verified = true
  user.email_credential.save!
  if i < 10
    role_name = 'staff'
    staff << user
  else
    role_name = 'grader'
    graders << user
  end
  Role.create! user: user, course: course, name: role_name
end

puts 'Staff created'

# Recitations.

time_slot_data = [
  { day: 0, starts_at: 1000, ends_at: 1200 },  # R10 (conflict for all students)
  { day: 1, starts_at: 1000, ends_at: 1100 },  # R01, R04
  { day: 2, starts_at: 1400, ends_at: 1500 },  # R02, R05
  { day: 3, starts_at: 1000, ends_at: 1100 },  # R03, R06
  { day: 4, starts_at: 1400, ends_at: 1500 },  # R04, R01
  { day: 5, starts_at: 1000, ends_at: 1100 },  # R05, R02
  { day: 6, starts_at: 1400, ends_at: 1500 },  # R06, R03
]

time_slot_ids = time_slot_data.map do |data|
  time_slot = TimeSlot.new data
  time_slot.course = course
  time_slot.save!
  time_slot.id
end

recitation_data = [
  { leader: staff[0], serial: 10, location: 'Room 0', time_slot_ids: [0, 3] },
  { leader: staff[0], serial: 1, location: 'Room 1', time_slot_ids: [1, 4] },
  { leader: staff[1], serial: 2, location: 'Room 2', time_slot_ids: [2, 5] },
  { leader: staff[2], serial: 3, location: 'Room 3', time_slot_ids: [3, 6] },
  { leader: staff[3], serial: 4, location: 'Room 4', time_slot_ids: [4, 1] },
  { leader: staff[4], serial: 5, location: 'Room 5', time_slot_ids: [5, 2] },
  { leader: staff[4], serial: 6, location: 'Room 6', time_slot_ids: [6, 3] }
]

recitation_data.each do |data|
  data[:time_slot_ids] = data[:time_slot_ids].map { |i| time_slot_ids[i] }
  data[:course] = course
  RecitationSection.create! data
end

conflict_data = {
  r10: [{ class_name: '7.01', time_slot_id: time_slot_ids[0] }],  # All students
  r01: [{ class_name: '8.01', time_slot_id: time_slot_ids[1] },   # R01 (1/2)
        { class_name: '8.01', time_slot_id: time_slot_ids[4] }]   # R01 (2/2)
}

students.each_with_index do |student, i|
  registration = student.registration_for course
  conflicts = (i % 30 == 0) ? conflict_data.values.flatten : conflict_data[:r10]
  registration.update recitation_conflicts_attributes: conflicts
end

partition = RecitationAssigner.new(course).partition!
partition.recitation_assignments.each do |assignment|
  registration = assignment.user.registration_for course
  registration.recitation_section = assignment.recitation_section
  registration.save!
end

puts 'Recitations assigned'

# Surveys.

survey_data = [
  { due_at: 1.week.ago, released: true },
  { due_at: 1.week.from_now, released: true },
  { due_at: 2.weeks.from_now, released: false }
]

surveys = survey_data.map.with_index do |data, index|
  i = index + 1

  survey = Survey.new name: "Survey #{i}"
  survey.course = course
  survey.due_at = data[:due_at]
  survey.released = data[:released]
  (1..3).map do |j|
    survey.questions.build prompt: Faker::Lorem.sentence, step_size: 1,
        allows_comments: (j % 2) == 0, type: QuantitativeOpenQuestion
  end
  (1..3).map do |j|
    survey.questions.build prompt: Faker::Lorem.sentence,
        allows_comments: (j % 2) == 0, type: QuantitativeScaledQuestion,
        scale_min: 1, scale_max: j + 5, scale_min_label: Faker::Lorem.word,
        scale_max_label: Faker::Lorem.word
  end
  survey.save!
  survey
end

([admin] + students).each_with_index do |user, i|
  surveys.each_with_index do |survey, j|
    next unless survey.released? && (i % (j + 2) == 0)
    response = SurveyResponse.new user: user, survey: survey, course: course
    survey.questions.each_with_index do |question, k|
      answer = response.answers.build question: question
      answer.number = rand(question.features[:scale_max] || 8)
      answer.comment = Faker::Lorem.sentence if question.allows_comments
    end
    response.save!
  end
end

puts 'Surveys created'

base_time = Time.current.beginning_of_minute

# Paper Exams - assignments without deliverables.

# TODO(spark008): Add more exams in different states.
paper_exam_data = [
  { due_at: -7.weeks, grades_released: true, state: :graded },
  { due_at: -5.days, grades_released: false, state: :grading },
  { due_at: 7.weeks, grades_released: false, state: :draft }
]

paper_exam_assignments = paper_exam_data.map.with_index do |data, index|
  i = index + 1

  assignment = Assignment.new name: "Paper Exam #{i}", weight: 5.0,
      author: admin, scheduled: true, enable_exam: '0'
  assignment.course = course
  assignment.build_deadline due_at: (base_time + data[:due_at]), course: course
  assignment.released_at = assignment.due_at - 1.week
  assignment.grades_released = data[:grades_released]
  assignment.save!
  (1..(5 + i)).map do |j|
    assignment.metrics.create! name: "Problem #{j}", weight: rand(20),
                               max_score: 6 + (i + j) % 6
  end
  assignment
end

students.each_with_index do |user, i|
  paper_exam_assignments.each_with_index do |assignment, j|
    next unless assignment.due_at < base_time
    assignment.metrics.each.with_index do |metric, k|
      next if i + j == k
      grade = metric.grades.build subject: user,
          score: metric.max_score * (0.1 * ((i + j + k) % 10)),
          course: metric.course, grader: admin
      grade.save!
    end
  end
end

puts 'Paper exams created'

# Homework - assignments with deliverables.

docker_analyzer_file = 'test/fixtures/files/analyzer/fib_small.zip'
docker_analyzer_params = { type: 'DockerAnalyzer', map_time_limit: '2',
    map_ram_limit: '1024', map_logs_limit: '1', reduce_time_limit: '2',
    reduce_ram_limit: '1024', reduce_logs_limit: '10',
    auto_grading: rand(2), db_file_attributes: {
    f: fixture_file_upload(docker_analyzer_file, 'application/zip', :binary) } }

homework_data = [
  { due_at: -12.weeks - 1.day, grades_released: true, scheduled: true },
  { due_at: -9.weeks - 1.day, grades_released: true, scheduled: true },
  { due_at: -6.weeks - 1.day, grades_released: true, scheduled: true },
  { due_at: -3.weeks - 1.day, grades_released: false, scheduled: true },
  { due_at: -1.day, grades_released: false, scheduled: true },
  { due_at: 1.week - 1.day, grades_released: false, scheduled: true },
  { due_at: 6.weeks - 1.day, grades_released: false, scheduled: true },
  { due_at: 9.weeks - 1.day, grades_released: false, scheduled: false },
]

homework_assignments = homework_data.map.with_index do |data, index|
  i = index + 1
  assignment = Assignment.new name: "Problem Set #{i}", weight: 1.0,
    author: staff[index]
  assignment.course = course
  assignment.build_deadline due_at: (base_time + data[:due_at]), course: course
  assignment.released_at = assignment.due_at - 1.week
  assignment.grades_released = data[:grades_released]
  assignment.scheduled = data[:scheduled]
  assignment.save!
  (1..(2 + i)).map do |j|
    assignment.metrics.create! name: "Problem #{j}", weight: rand(20),
                               max_score: 6 + (i + j) % 6

  end

  assignment.deliverables.create! name: 'PDF write-up',
      description: 'Please upload your write-up as a PDF.',
      analyzer_attributes: { type: 'ProcAnalyzer', message_name: 'analyze_pdf',
      auto_grading: true }

  assignment.deliverables.create! name: 'Fibonacci',
      description: 'Please upload your modified fib.py.',
      analyzer_attributes: docker_analyzer_params
  assignment
end

homework_assignments.each_with_index do |assignment, j|
  writeup = assignment.deliverables.find_by name: 'PDF write-up'
  writeup_upload = fixture_file_upload(
      'test/fixtures/files/submission/small.pdf', 'application/pdf', :binary)
  code = assignment.deliverables.find_by name: 'Fibonacci'
  code_upload = fixture_file_upload(
      'test/fixtures/files/submission/good_fib.py', 'text/x-python', :binary)

  ([admin] + staff + students).each_with_index do |user, i|
    next unless assignment.due_at < base_time

    unless (i + j) % 20 == 1
      # Submit PDF.
      time = assignment.due_at - 1.day + i * 1.minute
      submission = Submission.create! deliverable: writeup, uploader: user,
          upload_ip: '127.0.0.1', db_file_attributes: { f: writeup_upload },
          created_at: time, updated_at: time
      SubmissionAnalysisJob.perform_now submission
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end

    if (i + j) % 3 == 0
      # Submit code.
      time = assignment.due_at - 1.day + i * 1.minute + 30.seconds
      submission = Submission.create! deliverable: code, uploader: user,
          upload_ip: '127.0.0.1', db_file_attributes: { f: code_upload },
          created_at: time, updated_at: time
      SubmissionAnalysisJob.perform_now submission
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end

    next unless students.include?(user)

    # NOTE: the last condition is not a typo; we skip over some of the students
    #       who submitted the writeup, to test the "missing grades" finder
    unless (i + j) % 3 == 0 || (i + j) % 10 == 1
      # Submit grades.
      assignment.metrics.each.with_index do |metric, k|
        next if i + j == k

        grade = metric.grades.build subject: user,
            score: metric.max_score * (0.1 * ((i + j + k) % 10)),
            course: metric.course, grader: admin
        grade.created_at = assignment.due_at + 1.day
        grade.updated_at = assignment.due_at + 1.day
        grade.save!

        if (i + j) % 4 == 1
          comment = metric.comments.build subject: user, course: metric.course,
              grader: admin, text: Faker::Lorem.paragraphs(3).join("\n")
          comment.save!
        end
      end
    end
  end
end

puts 'Problem Sets created'

# Online Exams - assignments with exam sessions.

docker_analyzer_file = 'test/fixtures/files/analyzer/fib_small.zip'
docker_analyzer_params = { type: 'DockerAnalyzer', map_time_limit: '2',
    map_ram_limit: '1024', map_logs_limit: '1', reduce_time_limit: '2',
    reduce_ram_limit: '1024', reduce_logs_limit: '10',
    auto_grading: rand(2), db_file_attributes: {
    f: fixture_file_upload(docker_analyzer_file, 'application/zip', :binary) } }

online_exam_data = [
  { due_at: -7.weeks, grades_released: true, state: :graded },
  { due_at: -1.day, grades_released: false, state: :active },
  { due_at: 7.weeks, grades_released: false, state: :draft }
]

exam_sessions_data = [
  { starts_at: -2.days, ends_at: -1.day, capacity: 20,
    name: 'Main Session, Room 32-123' },
  { starts_at: -2.days, ends_at: -1.day, capacity: 20,
    name: 'Main Session, Room 32-144' },
  { starts_at: -12.hours, ends_at: 12.hours, capacity: 20,
    name: 'Makeup, Room 32-144' },
  { starts_at: 1.day, ends_at: 2.days, capacity: 20,
    name: 'Makeup, Makeup, Room 32-144' },
]

online_exam_assignments = online_exam_data.map.with_index do |data, index|
  i = index + 1

  assignment = Assignment.new name: "Online Exam #{i}", weight: 5.0,
      author: staff[index], scheduled: true, enable_exam: '1'
  assignment.course = course
  assignment.build_exam requires_confirmation: true
  assignment.build_deadline due_at: (base_time + data[:due_at]), course: course
  assignment.released_at = assignment.due_at - 1.week
  assignment.grades_released = data[:grades_released]
  assignment.save!
  (1..(2 + i)).map do |j|
    assignment.metrics.create! name: "Problem #{j}", weight: rand(20),
                               max_score: 6 + (i + j) % 6
  end

  sessions = exam_sessions_data.map do |session_data|
    assignment.exam.exam_sessions.create! name: session_data[:name],
        starts_at: assignment.due_at + session_data[:starts_at],
        ends_at: assignment.due_at + session_data[:ends_at],
        capacity: session_data[:capacity]
  end

  students.each_with_index do |student, student_index|
    i = student_index + 1
    session_index = i % (sessions.length + 1)
    next if session_index >= sessions.length

    confirmed = case data[:state]
    when :active
      i % (sessions.length + 1)
    when :graded
      true
    when :draft
      false
    end
    sessions[session_index].attendances.create! user: student,
        confirmed: confirmed, exam: assignment.exam
  end

  assignment.deliverables.create! name: 'PDF write-up',
      description: 'Please upload your write-up as a PDF.',
      analyzer_attributes: { type: 'ProcAnalyzer', message_name: 'analyze_pdf',
      auto_grading: true }

  assignment.deliverables.create! name: 'Fibonacci',
      description: 'Please upload your modified fib.py.',
      analyzer_attributes: docker_analyzer_params
  assignment
end

online_exam_assignments.each_with_index do |assignment, j|
  writeup = assignment.deliverables.find_by name: 'PDF write-up'
  writeup_upload = fixture_file_upload(
      'test/fixtures/files/submission/small.pdf', 'application/pdf', :binary)
  code = assignment.deliverables.find_by name: 'Fibonacci'
  code_upload = fixture_file_upload(
      'test/fixtures/files/submission/good_fib.py', 'text/x-python', :binary)

  ([admin] + staff + students).each_with_index do |user, i|
    next if assignment.released_at > base_time
    if students.include?(user) && !assignment.exam.confirmed_session_for(user)
      next
    end

    unless (i + j) % 20 == 1
      # Submit PDF.
      writeup = assignment.deliverables.find_by name: 'PDF write-up'
      time = assignment.due_at - 1.day + i * 1.minute
      submission = Submission.create! deliverable: writeup, uploader: user,
          upload_ip: '127.0.0.1', db_file_attributes: { f: writeup_upload },
          created_at: time, updated_at: time
      SubmissionAnalysisJob.perform_now submission
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end

    if (i + j) % 3 == 0
      # Submit code.
      code = assignment.deliverables.find_by name: 'Fibonacci'
      time = assignment.due_at - 1.day + i * 1.minute + 30.seconds
      submission = Submission.create! deliverable: code, uploader: user,
          upload_ip: '127.0.0.1', db_file_attributes: { f: code_upload },
          created_at: time, updated_at: time
      SubmissionAnalysisJob.perform_now submission
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end

    next unless students.include?(user)

    # NOTE: the last condition is not a typo; we skip over some of the students
    #       who submitted the writeup, to test the "missing grades" finder
    unless (i + j) % 3 == 0 || (i + j) % 10 == 1
      # Submit grades.
      assignment.metrics.each.with_index do |metric, k|
        next if i + j == k

        grade = metric.grades.build subject: user,
            score: metric.max_score * (0.1 * ((i + j + k) % 10)),
            course: metric.course, grader: admin
        grade.created_at = assignment.due_at + 1.day
        grade.updated_at = assignment.due_at + 1.day
        grade.save!

        if (i + j) % 4 == 1
          comment = metric.comments.build subject: user, course: metric.course,
              grader: admin, text: Faker::Lorem.paragraphs(3).join("\n")
          comment.save!
        end
      end
    end
  end
end

puts 'Online Exams created'


# TODO: Team projects.
