# == Schema Information
#
# Table name: exam_sessions
#
#  id        :integer          not null, primary key
#  course_id :integer          not null
#  exam_id   :integer          not null
#  name      :string(64)       not null
#  starts_at :datetime         not null
#  ends_at   :datetime         not null
#  capacity  :integer          not null
#

# The actual administration of an exam at a specified time/location.
class ExamSession < ActiveRecord::Base
  # The course administering this session.
  #
  # This is redundant, but helps find the exam sessions for a specific course.
  belongs_to :course, inverse_of: :exam_sessions
  # Get the course, if nil, from the exam.
  #
  # We always grab the course from the parent exam, rather than setting the
  # course only when setting the exam, since exam sessions are generally created
  # and updated as a nested attribute of the parent exam.
  def get_exam_course
    self.course = exam && exam.course
  end
  private :get_exam_course
  before_validation :get_exam_course

  # The exam that will be administered during this session.
  belongs_to :exam, inverse_of: :exam_sessions
  validates :exam, presence: true

  # The user-visible description of this session. E.g., 'Rm 32-123, 1.5x time'
  validates :name, length: 1..64, uniqueness: { scope: :exam }

  # The date/time when this session will begin.
  validates :starts_at, timeliness: true, presence: true

  # The date/time when this session will end.
  validates :ends_at, timeliness: { after: :starts_at, allow_nil: false }

  # The maximum number of students who may attend this session.
  validates :capacity, numericality: { allow_nil: false, greater_than: 0,
      greater_than_or_equal_to: proc { |record| record.attendances.count } }

  # The student attendances to this session.
  has_many :attendances, class_name: 'ExamAttendance', dependent: :destroy,
                         inverse_of: :exam_session

  # The assignment to be solved by the students taking this session's exam.
  has_one :assignment, through: :exam

  # Order sessions by start time, earliest to latest.
  scope :by_start_time, -> { order(:starts_at) }

  # Alphabetically order sessions by name.
  scope :by_name, -> { order(:name) }

  # The number of students who can still attend the given exam session.
  def available_seats
    capacity - attendances.count
  end

  # True if the session has not reached capacity yet.
  def has_available_seats?
    available_seats > 0
  end

  # True if the given user can check in to this session.
  #
  # Students should not be able to check-in to more than one session per exam.
  # Staff members should not be able to check in.
  def can_check_in?(user)
    course.is_student?(user) && has_available_seats? &&
        exam.attendances.find_by(user: user).nil?
  end

  # The given student's check-in status regarding this exam session.
  #
  # :available -- student can check-in to this exam session
  # :full -- exam session has reached capacity
  # :unavailable -- user may not check-in to this exam session, either because
  #   they are not a student, or because they have already checked-in elsewhere
  # :confirmed -- student may start the exam when this session begins
  # :pending_confirmation -- student has checked-in, staff has yet to confirm
  def ui_attendance_status_for(student)
    return :unavailable unless course.is_student? student
    attendance = exam.attendances.find_by user: student
    if attendance.nil?
      has_available_seats? ? :available : :full
    elsif attendance.exam_session_id == self.id
      attendance.confirmed? ? :confirmed : :pending_confirmation
    else
      has_available_seats? ? :unavailable : :full
    end
  end

  # Build a new attendance record for the given user and this session.
  def build_attendance_for_user(user)
    ExamAttendance.new user: user, exam_session: self,
                       confirmed: !exam.requires_confirmation?
  end
end
