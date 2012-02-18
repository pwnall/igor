# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Course.

course = Course.main
course.update_attributes! number: '1.337', title: 'Intro to Pwnage',
    has_recitations: false, has_surveys: false, has_teams: false
prereq1 = Prerequisite.new prerequisite_number: '6.01',
                           waiver_question: 'Programming experience'
prereq1.course = course
prereq1.save!

prereq2 = Prerequisite.new prerequisite_number: '6.042',
                           waiver_question: 'Math experience'
prereq2.course = course
prereq2.save!

# Staff.

admin = User.create email: 'costan@mit.edu', password: 'mit',
                    password_confirmation: 'mit'
admin.email_credential.verified = true
admin.admin = true
admin.save!

admin_profile = Profile.create! user: admin, name: 'Victor Costan',
    nickname: 'Victor', university: 'MIT', department: 'EECS',
    year: 'G', athena_username: 'costan', about_me: "I'm the boss"

admin_registration = Registration.new for_credit: false, allows_publishing: true    
admin_registration.user = admin
admin_registration.course = course
admin_registration.save!

PrerequisiteAnswer.create! registration: admin_registration,
    prerequisite: prereq1, took_course: false,
    waiver_answer: 'Gold medal at IOI 2003'
PrerequisiteAnswer.create! registration: admin_registration,
    prerequisite: prereq2, took_course: true, waiver_answer: nil

# Students.

names = File.read('db/seeds/names.txt').split("\n").
    map { |line| line.split('.', 2).last.strip }
depts = File.read('db/seeds/depts.txt').split("\n").
    map { |line| line.split('(', 2).first.strip }

users = []
names.each_with_index do |name, i|
  first_name = name.split(' ').first
  short_name = (first_name[0, 1] + name.split(' ').last).downcase
  user = User.create email: short_name + '@mit.edu',  password: 'mit',
                     password_confirmation: 'mit'
  user.email_credential.verified = true
  user.save!
  users << user
  
  Profile.create! user: user, name: name, nickname: first_name,
      athena_username: short_name, university: 'MIT', year: (1 + (i % 4)).to_s,
      department: depts[i % depts.length], about_me: "Test subject #{i + 1}"

  registration = Registration.new for_credit: (i % 5 < 4),
                                  allows_publishing: (i % 7 < 5)
  registration.user = user
  registration.course = course

  PrerequisiteAnswer.create! registration: registration,
      prerequisite: prereq1, took_course: (i % 2 == 0),
      waiver_answer: (i % 2 == 0) ? nil :
                     'Silver medal at IOI 2011... bitches'
  PrerequisiteAnswer.create! registration: registration,
      prerequisite: prereq2, took_course: (i % 4 < 2),
      waiver_answer: (i % 4 < 2) ? nil :
                     'Bronze medal at IMO 2011, A+ in 18.something'
end

# Exams.

exam_data = [
  { deadline: -6.weeks - 5.days, state: :graded },
  { deadline: -5.days, state: :draft },
  { deadline: 8.weeks - 5.days, state: :draft }
]

exams = exam_data.map.with_index do |data, index|
  i = index + 1
  
  exam = Assignment.new name: "Exam #{i}", weight: 5.0, author: admin,
                        deadline: Time.now + data[:deadline]
  exam.course = course
  exam.deliverables_ready = data[:state] != :draft
  exam.metrics_ready = data[:state] == :graded
  exam.save!
  metrics = (1..(5 + i)).map do |j|
    AssignmentMetric.create! assignment: exam, name: "Problem #{j}",
                             max_score: 6 + (i + j) % 6
  end

  raise "Exam #{i} seeding bug" unless exam.ui_state_for(admin) == data[:state]
  exam
end

([admin] + users).each_with_index do |user, i|
  exams.each_with_index do |exam, j|
    next unless exam.deadline < Time.now
    exam.metrics.each_with_index do |metric, k|
      next if i + j == k
      Grade.create! subject: user, grader: admin, metric: metric,
                    score: metric.max_score * (0.1 * ((i + j + k) % 10))
    end
  end
end

# Psets.

# fixture_file_upload from Rails, tweaked to use spec/fixtures.
def fixture_file_upload(path, mime_type)
  Rack::Test::UploadedFile.new 'spec/fixtures/' + path, mime_type, true
end

pset_data = [
  { deadline: -12.weeks - 1.day, state: :graded },
  { deadline: -9.weeks - 1.day, state: :graded },
  { deadline: -6.weeks - 1.day, state: :graded },
  { deadline: -3.weeks - 1.day, state: :grading },
  { deadline: -1.day, state: :grading },
  { deadline: 3.weeks - 1.day, state: :open },
  { deadline: 6.weeks - 1.day, state: :open },
  { deadline: 9.weeks - 1.day, state: :draft }
]

psets = pset_data.map.with_index do |data, index|
  i = index + 1
  pset = Assignment.new name: "Problem Set #{i}", weight: 1.0, author: admin,
                        deadline: Time.now + data[:deadline]
  pset.course = course
  pset.deliverables_ready = data[:state] != :draft
  pset.metrics_ready = data[:state] == :graded
  pset.save!
  metrics = (1..(2 + i)).map do |j|
    AssignmentMetric.create! assignment: pset, name: "Problem #{j}",
                             max_score: 6 + (i + j) % 6
  end
  
  pdf_deliverable = Deliverable.create! assignment: pset,
      name: 'PDF write-up', file_ext: 'pdf',
      description: 'Please upload your write-up, in PDF format.'
  analyzer = ProcAnalyzer.new  message_name: 'analyze_pdf', auto_grading: true
  analyzer.deliverable = pdf_deliverable
  analyzer.save!
  
  rb_deliverable = Deliverable.create! assignment: pset,
      name: 'Fibonacci', file_ext: 'rb',
      description: 'Please upload your modified fib.rb.'
  analyzer = ScriptAnalyzer.new db_file_attributes: {
      f: fixture_file_upload('analyzer_files/fib.zip', 'application/zip') },
      time_limit: '2', ram_limit: '1024', process_limit: '5',
      file_limit: '10', file_size_limit: '100', input_file: 'fib.rb',
      auto_grading: false
  analyzer.deliverable = rb_deliverable
  analyzer.save!

  raise "Pset #{i} seeding bug" unless pset.ui_state_for(admin) == data[:state]
  pset
end

([admin] + users).each_with_index do |user, i|
  psets.each_with_index do |pset, j|
    next unless pset.deadline < Time.now
    
    unless (i + j) % 20 == 1
      # Submit PDF.
      writeup = pset.deliverables.where(file_ext: 'pdf').first
      pdf = Prawn::Document.new page_size: 'LETTER', page_layout: :portrait
      pdf.y = 792 - 36
      pdf.font "Times-Roman"
      pdf.text user.email, align: :left, size: 24
      pdf.text user.name, align: :left, size: 24
      pdf.text pset.name, align: :left, size: 24
      pdf_contents = pdf.render
      
      time = pset.deadline - 1.day + i * 1.minute
      submission = Submission.create! deliverable: writeup, user: user,
           db_file_attributes: {
             f: fixture_file_upload('submission_files/small.pdf',
                                    'application/pdf')
           }, created_at: time, updated_at: time
      submission.run_analysis
      submission.analysis.created_at = time + 1.second
      submission.analysis.updated_at = time + 5.seconds
      submission.analysis.save!
    end
    
    if (i + j) % 3 == 0
      # Submit code.
      code = pset.deliverables.where(file_ext: 'rb').first
      time = pset.deadline - 1.day + i * 1.minute + 30.seconds
      submission = Submission.create! deliverable: code, user: user,
           db_file_attributes: {
             f: fixture_file_upload('submission_files/good_fib.rb',
                                    'application/x-ruby')
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
      pset.metrics.each_with_index do |metric, k|
        next if i + j == k
        Grade.create! subject: user, grader: admin, metric: metric,
            score: metric.max_score * (0.1 * ((i + j + k) % 10)),
            created_at: pset.deadline + 1.day, updated_at: pset.deadline + 1.day
      end
    end
  end
end

# TODO: Projects.

