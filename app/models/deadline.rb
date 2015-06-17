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
  validates :course, uniqueness: { scope: [:subject_id, :subject_type] },
      presence: true
end
