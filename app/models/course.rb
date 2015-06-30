# == Schema Information
#
# Table name: courses
#
#  id                     :integer          not null, primary key
#  number                 :string(16)       not null
#  title                  :string(256)      not null
#  ga_account             :string(32)       not null
#  email                  :string(64)       not null
#  email_on_role_requests :boolean          not null
#  has_recitations        :boolean          not null
#  has_surveys            :boolean          not null
#  has_teams              :boolean          not null
#  section_size           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

# A bunch of work that results in with grades for registered students.
class Course < ActiveRecord::Base
  # The course number (e.g. "6.006")
  validates :number, length: 1..16, presence: true
  # The course title (e.g. "Introoduction to Algorithms").
  validates :title, length: 1..256, presence: true
  # The contact e-mail for course staff.
  validates :email, length: 1..64, presence: true
  # True if requests for course-specific privileges e-mail the staff.
  validates :email_on_role_requests, inclusion: { in: [true, false],
                                                  allow_nil: false }

  # True if the course has recitation sections.
  validates :has_recitations, inclusion: { in: [true, false], allow_nil: false }

  # Maximum number of students per recitation.
  #
  # TODO: Take this attribute out of the Course model and move it into the
  #     recitation partitioning/assigning code.
  validates :section_size,
      numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # Surveys on the difficulty of an assignment, general feedback, etc.
  has_many :surveys, dependent: :destroy, inverse_of: :course
  # True if the course has surveys.
  validates :has_surveys, inclusion: { in: [true, false], allow_nil: false }
  # True if the course has homework teams.
  validates :has_teams, inclusion: { in: [true, false], allow_nil: false }

  # Google Analytics account ID for the course.
  validates :ga_account, length: 1..32, presence: true

  # Student registrations for this course.
  has_many :registrations, dependent: :destroy, inverse_of: :course

  # Prerequisite courses for this course.
  has_many :prerequisites, dependent: :destroy, inverse_of: :course

  # Assignments issued for this course.
  has_many :assignments, dependent: :destroy, inverse_of: :course

  # The deadlines for all assignments and surveys in this course.
  has_many :deadlines, -> { order(due_at: :desc) }, dependent: :destroy,
      inverse_of: :course

  # Sections for this course's recitations.
  has_many :recitation_sections, dependent: :destroy, inverse_of: :course

  # The time periods pre-allocated for this course's recitations.
  has_many :time_slots, dependent: :destroy, inverse_of: :course

  # The students in this course.
  has_many :users, through: :registrations, source: :user

  # The course-specific privileges assigned for this course.
  has_many :roles, inverse_of: :course, dependent: :destroy

  # The requests for course-specific privileges for this course.
  has_many :role_requests, inverse_of: :course, dependent: :destroy

  # Students registered for this course.
  def students
    User.joins(:registrations).where(
        registrations: { course_id: id, dropped: false })
  end

  # Course staff members.
  def staff
    User.joins(:roles).where roles: { name: 'staff', course_id: id }
  end

  # Graders for the course.
  def graders
    User.joins(:roles).where roles: { name: 'grader', course_id: id }
  end

  # The main (and only) course on the website.
  def self.main
    first
  end
end
