# == Schema Information
#
# Table name: exams
#
#  id                    :integer          not null, primary key
#  assignment_id         :integer          not null
#  requires_confirmation :boolean          not null
#

# An assignment that is administered at specified times/locations.
class Exam < ApplicationRecord
  # The content that will be administered during the exam sessions.
  belongs_to :assignment, inverse_of: :exam
  validates :assignment, presence: true, uniqueness: true

  # True if a staff member must confirm student attendance to exam sessions.
  validates :requires_confirmation, inclusion: { in: [true, false],
                                                 allow_nil: false }
  # If :requires_confirmation changes, existing attendances should be updated.
  def reset_confirmations
    attendances.update_all confirmed: !requires_confirmation
  end
  after_update :reset_confirmations, if: :saved_change_to_requires_confirmation?

  # The times/locations where this exam is administered.
  has_many :exam_sessions, dependent: :destroy, inverse_of: :exam
  accepts_nested_attributes_for :exam_sessions, allow_destroy: true

  # The student check-ins logged for this exam's sessions.
  has_many :attendances, class_name: 'ExamAttendance', inverse_of: :exam

  # The course administering this exam.
  has_one :course, through: :assignment

  # Looks up the session when a student will be taking this exam.
  #
  # @param [User] student the student whose session is looked up
  # @return [ExamSession?] the session when the given user will be taking
  #   this exam; nil if the user has not signed up for an exam session, or if
  #   the user's attendance was not confirmed
  def confirmed_session_for(student)
    attendance = attendances.where(user: student).includes(:exam_session).first
    return nil if attendance.nil? || !attendance.confirmed?
    attendance.exam_session
  end
end
