# == Schema Information
#
# Table name: deadline_extensions
#
#  id           :integer          not null, primary key
#  subject_type :string           not null
#  subject_id   :integer          not null
#  user_id      :integer          not null
#  grantor_id   :integer
#  due_at       :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# An extended deadline granted to a student for an assignment.
class DeadlineExtension < ActiveRecord::Base
  # The assignment (or survey) whose deadline has been extended.
  belongs_to :subject, polymorphic: true, inverse_of: :extensions
  validates :subject, presence: true

  # The student who was granted the extension.
  belongs_to :user
  validates :user, uniqueness: { scope: [:subject_id, :subject_type] }
  validates_each :user do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.subject && !record.subject.course.is_student?(value)
      record.errors.add attr, 'is not registered for the course'
    end
  end

  # The course/site admin who granted the user this extension.
  belongs_to :grantor, class_name: 'User'
  validates_each :grantor do |record, attr, value|
    if value && record.subject && !record.subject.course.can_edit?(value)
      record.errors.add attr, 'is not a staff member in this course'
    end
  end

  # The extended due date.
  validates :due_at, presence: true,
      timeliness: { after: Proc.new { |extension| extension.subject.due_at } }

  # The recipient's external id (virtual attribute).
  def user_exuid
    user && user.to_param
  end

  # Set the extension's recipient (virtual attribute).
  def user_exuid=(exuid)
    self.user = User.find_by_param exuid
  end
end
