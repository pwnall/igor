# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Course.

course = Course.main
prereq1 = Prerequisite.create! :course => course,
    :prerequisite_number => '6.01', :waiver_question => 'Programming experience'
prereq2 = Prerequisite.create! :course => course,
    :prerequisite_number => '6.042', :waiver_question => 'Math experience'

# Staff.

admin = User.create :email => 'costan@mit.edu', :password => 'mit',
    :password_confirmation => 'mit', :active => true, :admin => true
admin.active = true
admin.admin = true
admin.save!

admin_profile = Profile.create! :user => admin, :real_name => 'Victor Costan',
    :nickname => 'Victor', :university => 'MIT', :department => 'EECS',
    :year => 'G', :athena_username => 'costan', :about_me => "I'm the boss",
    :allows_publishing => true

# Students.

names = File.read('db/seeds/names.txt').split("\n").
    map { |line| line.split('.', 2).last.strip }
depts = File.read('db/seeds/depts.txt').split("\n").
    map { |line| line.split('(', 2).first.strip }

users = []
names.each_with_index do |name, i|
  first_name = name.split(' ').first
  short_name = (name.split(' ').last + first_name[0, 1]).downcase
  user = User.create :email => short_name + '@mit.edu', 
       :password => 'password', :password_confirmation => 'password'
  user.active = true
  user.save!
  users << user
  
  Profile.create! :user => user, :real_name => name,
      :nickname => first_name, :university => 'MIT', :allows_publishing => true,
      :department => depts[i % depts.length], :year => (1 + (i % 4)).to_s,
      :athena_username => short_name, :about_me => "Test subject #{i + 1}"

  registration = Registration.create! :user => user, :course => course,
      :dropped => false, :for_credit => (i % 2 == 0),
      :motivation => "Test subject #{i + 1}"

  PrerequisiteAnswer.create! :registration => registration,
      :prerequisite => prereq1, :took_course => (i % 2 == 0),
      :waiver_answer => (i % 2 == 0) ? nil :
                        'Silver medal at IOI 2011... bitches'
  PrerequisiteAnswer.create! :registration => registration,
      :prerequisite => prereq2, :took_course => (i % 4 < 2),
      :waiver_answer => (i % 4 < 2) ? nil :
                        'Bronze medal at IMO 2011, A+ in 18.something'
end

# Homework.

psets = (1..8).map do |i|
  pset = Assignment.create! :course => course, :name => "Problem Set #{i}",
      :deadline => Time.now - 1.day - 5.weeks + i * 1.week
  published = pset.deadline < Time.now
  metrics = (1..(2 + i)).map do |j|
    AssignmentMetric.create! :assignment => pset, :name => "Problem #{j}",
      :published => published, :weight => 1.0, :max_score => 6 + (i + j) % 6
  end
  
  Deliverable.create! :assignment => pset, :name => 'PDF write-up',
      :description => 'Please upoad your write-up, in PDF format.',
      :published => i < 8, :filename => 'writeup.pdf'
end

exams = (1..3).map do |i|
  exam = Assignment.create! :course => course, :name => "Exam #{i}",
      :deadline => Time.now - 2.weeks - 6.weeks + i * 4.weeks
  metrics = (1..(5 + i)).map do |j|
    AssignmentMetric.create! :assignment => exam, :name => "Problem #{j}",
      :published => (exam.deadline < Time.now), :weight => 1.0,
      :max_score => 6 + (i + j) % 6
  end
end
