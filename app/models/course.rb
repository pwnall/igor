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
  validates :number, length: 1..16, presence: true, uniqueness: true
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

  # True if the course has surveys.
  validates :has_surveys, inclusion: { in: [true, false], allow_nil: false }

  # True if the course has homework teams.
  validates :has_teams, inclusion: { in: [true, false], allow_nil: false }

  # Google Analytics account ID for the course.
  validates :ga_account, length: 1..32, presence: true

  # Use the course ID as the parameter field.
  def to_param
    number
  end

  # The main (and only) course on the website.
  def self.main
    first
  end
end

# :nodoc: Students.
class Course
  # The students in this course.
  has_many :users, through: :registrations, source: :user

  # Student registrations for this course.
  has_many :registrations, dependent: :destroy, inverse_of: :course

  # Prerequisite courses for this course.
  has_many :prerequisites, dependent: :destroy, inverse_of: :course

  # Students registered for this course.
  def students
    User.joins(:registrations).where(
        registrations: { course_id: id, dropped: false })
  end

  # True if the given user is registered for this class.
  def is_student?(user)
    # NOTE: We're not doing an exist? query here because we expect that the
    #       Registration record will be fetched when this check passes. The
    #       query cache will be able to reuse the resullts of the query issued
    #       below, so we're saving one SQL query.
    !!Registration.where(course: self, user: user).first
  end
end

# :nodoc: Staff permissions.
class Course
  # The course-specific privileges assigned for this course.
  has_many :roles, inverse_of: :course, dependent: :destroy

  # The requests for course-specific privileges for this course.
  has_many :role_requests, inverse_of: :course, dependent: :destroy

  # True if the given user belongs to the course staff.
  def is_staff?(user)
    Role.has_entry? user, :staff, self
  end

  # True if the user is a grader for the course.
  def is_grader?(user)
    Role.has_entry? user, :grader, self
  end

  # True if the given user can edit the course information.
  def can_edit?(user)
    is_staff?(user) || !!(user && user.admin?)
  end

  # True if the given user can post grades to the course.
  def can_grade?(user)
    is_grader?(user) || is_staff?(user) ||
        (!!user && (user.admin? || user.robot?))
  end

  # Course staff members.
  def staff
    User.joins(:roles).where roles: { name: 'staff', course_id: id }
  end

  # Graders for the course.
  def graders
    User.joins(:roles).where roles: { name: 'grader', course_id: id }
  end
end

# :nodoc: Homework.
class Course
  # Assignments issued for this course.
  has_many :assignments, dependent: :destroy, inverse_of: :course

  # The assignment that was either due last, or created last.
  #
  # This method is used by the grade editor to predict which assignment a grader
  #     would be most interested in seeing.
  def most_relevant_assignment_for_graders
    assignments.by_deadline.past_due.first || assignments.last
  end

  # The assignments in this course that are visible to the given user.
  def assignments_for(user)
    assignments.by_deadline.select { |a| a.can_read? user }
  end

  # The deadlines for all assignments and surveys in this course.
  has_many :deadlines, -> { order(due_at: :desc) }, dependent: :destroy,
      inverse_of: :course

  # The grading metrics defined for this course.
  has_many :assignment_metrics, through: :assignments, source: :metrics

  # The deliverables defined for this course.
  has_many :deliverables, through: :assignments
end

# :nodoc: Recitation sections.
class Course
  # Sections for this course's recitations.
  has_many :recitation_sections, dependent: :destroy, inverse_of: :course

  # Proposals for assigning this course's students to recitations.
  has_many :recitation_partitions, dependent: :destroy, inverse_of: :course

  # The time periods pre-allocated for this course's recitations.
  has_many :time_slots, dependent: :destroy, inverse_of: :course

  # Days when registrations for this course may have recitation conflicts.
  #
  # @return [Array<Integer>] the days, in integer representation
  def days_with_time_slots
    time_slots.map(&:day).uniq.sort!
  end

  # The course's time slots, indexed by start and end time.
  #
  # @return [Hash<Array<Integer, Integer>, TimeSlot] the time slots, indexed by
  #   their :starts_at and :ends_at attributes
  def time_slots_by_period
    slots_by_period = time_slots.group_by { |ts| [ts.starts_at, ts.ends_at] }
    slots_by_period.each do |period, slots|
      slots_by_period[period] = slots.index_by(&:day)
    end
  end
end

# :nodoc: Surveys.
class Course
  # Surveys on the difficulty of an assignment, general feedback, etc.
  has_many :surveys, dependent: :destroy, inverse_of: :course

  # Responses to surveys administered in this course.
  has_many :survey_responses, inverse_of: :course

  # The surveys in this course that are visible to the given user.
  def surveys_for(user)
    surveys.by_deadline.select { |s| s.can_respond? user }
  end
end

# :nodoc: Teams
class Course
  # Groupings of students into teams for this course.
  has_many :team_partitions, dependent: :destroy, inverse_of: :course

  # Assignments of students to teams for this course.
  has_many :team_memberships, inverse_of: :course
end

# :nodoc: Announcements.
class Course
  # The announcements made in this course.
  has_many :announcements, dependent: :destroy, inverse_of: :course
end
