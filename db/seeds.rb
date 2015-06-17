# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

include ActionDispatch::TestProcess  # Want fixture_file_upload.

# Course.

puts 'Starting seeds'

Course.destroy_all
course = Course.new
course.update_attributes! number: '1.337', title: 'Intro to Pwnage',
    email: Rails.application.secrets.gmail_email,
    ga_account: "faketest",
    email_on_role_requests: true,
    has_recitations: false, has_surveys: false, has_teams: false,
    section_size: 20

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
admin = User.create! email: 'costan@mit.edu', password: 'mit',
    password_confirmation: 'mit', profile_attributes: {
      athena_username: 'costan', name: 'Victor Costan', nickname: 'Victor',
      university: 'MIT', department: 'EECS', year: 'G'
    }
admin.email_credential.verified = true
admin.save!
Role.create! user: admin, name: 'admin'

puts 'Admin created'

# Students.

names = File.read('db/seeds/names.txt').split("\n").
    map { |line| line.split('.', 2).last.strip }
depts = File.read('db/seeds/depts.txt').split("\n").
    map { |line| line.split('(', 2).first.strip }

users = []
names.each_with_index do |name, i|
  first_name = name.split(' ').first
  short_name = (first_name[0, 1] + name.split(' ').last).downcase
  user = User.create! email: short_name + '@mit.edu',  password: 'mit',
      password_confirmation: 'mit', profile_attributes: {
        athena_username: short_name, name: name, nickname: first_name,
        university: 'MIT', year: (1 + (i % 4)).to_s,
        department: depts[i % depts.length]
      }
  user.email_credential.verified = true
  user.email_credential.save!
  users << user

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

# Staff.

staff = []
graders = []
1.upto 14 do |i|
  name = Faker::Name.name
  first_name = name.split(' ').first
  short_name = (first_name[0, 1] + name.split(' ').last).downcase
  user = User.create! email: short_name + '@mit.edu',  password: 'mit',
      password_confirmation: 'mit', profile_attributes: {
        athena_username: short_name, name: name, nickname: first_name,
        university: 'MIT', year: (1 + (i % 4)).to_s,
        department: depts[i % depts.length]
      }
  user.email_credential.verified = true
  user.email_credential.save!
  if i <= 10
    role_name = 'staff'
    staff << user
  else
    role_name = 'grader'
    graders << user
  end
  Role.create! user: user, course: course, name: role_name
end

puts 'Staff created'


# Exams.

exam_data = [
  { due_at: -6.weeks - 5.days, state: :graded },
  { due_at: -5.days, state: :draft },
  { due_at: 8.weeks - 5.days, state: :draft }
]

exams = exam_data.map.with_index do |data, index|
  i = index + 1

  exam = Assignment.new name: "Exam #{i}", weight: 5.0, author: admin
  exam.course = course
  exam.build_deadline due_at: (Time.now + data[:due_at]), course: course
  exam.deliverables_ready = data[:state] != :draft
  exam.metrics_ready = data[:state] == :graded
  exam.save!
  (1..(5 + i)).map do |j|
    exam.metrics.build name: "Problem #{j}", max_score: 6 + (i + j) % 6
  end

  raise "Exam #{i} seeding bug" unless exam.ui_state_for(admin) == data[:state]
  exam
end

([admin] + users).each_with_index do |user, i|
  exams.each_with_index do |exam, j|
    next unless exam.due_at < Time.now
    exam.metrics.each.with_index do |metric, k|
      next if i + j == k
      grade = metric.grades.build subject: user,
          score: metric.max_score * (0.1 * ((i + j + k) % 10))
      grade.grader = admin
      grade.save!
    end
  end
end

puts 'Exams created'

# Psets.

pset_data = [
  { due_at: -12.weeks - 1.day, state: :graded },
  { due_at: -9.weeks - 1.day, state: :graded },
  { due_at: -6.weeks - 1.day, state: :graded },
  { due_at: -3.weeks - 1.day, state: :grading },
  { due_at: -1.day, state: :grading },
  { due_at: 3.weeks - 1.day, state: :open },
  { due_at: 6.weeks - 1.day, state: :open },
  { due_at: 9.weeks - 1.day, state: :draft }
]

psets = pset_data.map.with_index do |data, index|
  i = index + 1
  pset = Assignment.new name: "Problem Set #{i}", weight: 1.0, author: admin
  pset.course = course
  pset.build_deadline due_at: (Time.now + data[:due_at]), course: course
  pset.deliverables_ready = data[:state] != :draft
  pset.metrics_ready = data[:state] == :graded
  pset.save!
  (1..(2 + i)).map do |j|
    pset.metrics.create! name: "Problem #{j}", max_score: 6 + (i + j) % 6
  end

  pdf_deliverable = pset.deliverables.create! name: 'PDF write-up',
      file_ext: 'pdf',
      description: 'Please upload your write-up, in PDF format.'
  analyzer = ProcAnalyzer.new  message_name: 'analyze_pdf', auto_grading: true
  analyzer.deliverable = pdf_deliverable
  analyzer.save!

  rb_deliverable = pset.deliverables.create! assignment: pset,
      name: 'Fibonacci', file_ext: 'rb',
      description: 'Please upload your modified fib.rb.'
  analyzer_file = 'test/fixtures/analyzer_files/' +
      ((i % 2 == 1) ? 'fib_grading.zip' : 'fib.zip')
  analyzer = ScriptAnalyzer.new db_file_attributes: {
      f: fixture_file_upload(analyzer_file, 'application/zip', :binary) },
      time_limit: '2', ram_limit: '1024', process_limit: '5',
      file_limit: '10', file_size_limit: '100', auto_grading: (i % 2 == 1)
  analyzer.deliverable = rb_deliverable
  analyzer.save!

  unless pset.ui_state_for(admin) == data[:state]
    raise "Pset #{i} seeding bug: #{data[:state]} / #{pset.ui_state_for(admin)}"
  end
  pset
end

([admin] + users).each_with_index do |user, i|
  psets.each_with_index do |pset, j|
    next unless pset.due_at < Time.now

    unless (i + j) % 20 == 1
      # Submit PDF.
      writeup = pset.deliverables.where(file_ext: 'pdf').first
      time = pset.due_at - 1.day + i * 1.minute
      submission = Submission.create! deliverable: writeup, subject: user,
           db_file_attributes: {
             f: fixture_file_upload('test/fixtures/submission_files/small.pdf',
                                    'application/pdf', :binary)
           }, created_at: time, updated_at: time
      submission.run_analysis
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end

    if (i + j) % 3 == 0
      # Submit code.
      code = pset.deliverables.where(file_ext: 'rb').first
      time = pset.due_at - 1.day + i * 1.minute + 30.seconds
      submission = Submission.create! deliverable: code, subject: user,
          db_file_attributes: {
            f: fixture_file_upload(
                'test/fixtures/submission_files/good_fib.rb',
                'text/x-ruby', :binary)
          }, created_at: time, updated_at: time
      submission.run_analysis
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end

    # NOTE: the last condition is not a typo; we skip over some of the students
    #       who submitted the writeup, to test the "missing grades" finder
    unless (i + j) % 3 == 0 || (i + j) % 10 == 1
      # Submit grades.
      pset.metrics.each.with_index do |metric, k|
        next if i + j == k

        grade = metric.grades.build subject: user,
            score: metric.max_score * (0.1 * ((i + j + k) % 10))
        grade.grader = admin
        grade.created_at = pset.due_at + 1.day
        grade.updated_at = pset.due_at + 1.day
        grade.save!

        if (i + j) % 4 == 1
          comment = GradeComment.new grade: grade, grader: admin,
              comment: Faker::Lorem.paragraphs(3).join("\n")
          comment.save!
        end
      end
    end
  end
end

puts 'Psets created'

# TODO: Projects.
