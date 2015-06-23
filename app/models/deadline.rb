# == Schema Information
#
# Table name: deadlines
#
#  id           :integer          not null, primary key
#  subject_type :string(255)      not null
#  subject_id   :integer          not null
#  due_at       :datetime         not null
#  course_id    :integer          not null
#

# The deadline for an assignment or a feedback survey.
class Deadline < ActiveRecord::Base
  # The assignment or survey that enforces this deadline.
  belongs_to :subject, polymorphic: true
  validates :subject, presence: true
  validates :subject_id, uniqueness: { scope: [:subject_type] }

  # The date when the subject is due.
  validates :due_at, presence: true, timeliness: true

  # The course in which the assignment or survey is administered.
  belongs_to :course, inverse_of: :deadlines
  # Get the course, if nil, from the subject before validating its presence.
  before_validation :get_subject_course
  def get_subject_course
    self.course = subject.course if subject && course.nil?
  end
  private :get_subject_course
  validates :course, uniqueness: { scope: [:subject_id, :subject_type] },
      presence: true

  # Ensures that the course matches the subject's course.
  def course_matches_subject
    return unless subject && course
    return if subject.course_id == course_id
    errors.add :course, 'does not match the course of the subject.'
  end
  private :course_matches_subject
  validate :course_matches_subject
end
