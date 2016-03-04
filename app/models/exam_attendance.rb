# == Schema Information
#
# Table name: exam_attendances
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  exam_id         :integer          not null
#  exam_session_id :integer          not null
#  confirmed       :boolean          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# A student's attendance at a particular exam session.
class ExamAttendance < ApplicationRecord
  # The student who is attending the exam session.
  belongs_to :user, inverse_of: :exam_attendances
  validates :user, presence: true, uniqueness: { scope: :exam }
  validates_each :user do |record, attr, value|
    if value && record.exam && !record.exam.course.is_student?(value)
      record.errors.add attr, 'is not a registered student for this course'
    end
  end

  # The exam administered at the attended session.
  #
  # This is redundant, but helps find the students attending an exam.
  belongs_to :exam, inverse_of: :attendances

  # Ensures that the exam matches the exam session's exam.
  validates_each :exam do |record, attr, value|
    if record.exam_session && record.exam_session.exam != value
      record.errors.add attr, "does not match the exam session's course"
    end
  end

  # The exam session that the student is attending.
  belongs_to :exam_session, inverse_of: :attendances
  validates_each :exam_session do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.new_record? && !value.has_available_seats?
      record.errors.add attr, 'has reached capacity'
    end
  end
  def exam_session=(new_exam_session)
    self.exam = new_exam_session && new_exam_session.exam
    super
  end

  # True if the student's attendance has been confirmed.
  #
  # If the exam requires attendance to be confirmed, then the confirmation must
  # be completed by a staff member. Otherwise, attendance should be
  # auto-confirmed.
  validates :confirmed, inclusion: { in: [true, false], allow_nil: false }

  # The course facilitating the exam session.
  has_one :course, through: :exam_session

  # Alphabetically order attendances by the student's name.
  scope :by_student_name, lambda { includes(user: :profile).
      sort_by { |attendance| attendance.user.name } }
end
