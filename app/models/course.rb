# A bunch of work that results in with grades for registered students.
class Course < ActiveRecord::Base
  # The course number (e.g. "6.006")
  validates :number, length: 1..16, presence: true
  # The course title (e.g. "Introoduction to Algorithms").
  validates :title, length: 1..256, presence: true
  # The contact e-mail for course staff.
  validates :email, length: 1..64, presence: true
  # True if the course has recitation sections.
  validates :has_recitations, inclusion: { in: [true, false], allow_nil: false }
  validates :recitation_size, numericality: { only_integer: true, greater_than: 0 } 
  # True if the course has homework surveys.
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

  # All users connected to this course.
  has_many :users, through: :registrations, source: :user

  # Students registered for this course.
  def students
    users.joins(:registrations).where(admin: false,
        registrations: { course_id: id, dropped: false })
  end

  # Course staff members.
  def staff
    users.where admin: true
  end

  # The main (and only) course on the website.
  def self.main
    first
  end
end

# == Schema Information
#
# Table name: courses
#
#  id              :integer(4)      not null, primary key
#  number          :string(16)      not null
#  title           :string(256)     not null
#  ga_account      :string(32)      not null
#  email           :string(64)      not null
#  has_recitations :boolean(1)      default(TRUE), not null
#  has_surveys     :boolean(1)      default(TRUE), not null
#  has_teams       :boolean(1)      default(TRUE), not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

