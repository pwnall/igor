# == Schema Information
#
# Table name: surveys
#
#  id         :integer          not null, primary key
#  name       :string(128)      not null
#  released   :boolean          not null
#  course_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# The set of questions used in a survey.
class Survey < ApplicationRecord
  include HasDeadline

  # A name for the question set. Visible to admins.
  validates :name, length: { in: 1..128, allow_nil: false },
      uniqueness: { scope: :course }

  # Whether the survey has been released and users can submit responses.
  validates :released, inclusion: { in: [true, false], allow_nil: false }

  # The course in which this survey is administered.
  belongs_to :course, inverse_of: :surveys
  validates :course, presence: true

  # The questions that constitute this survey.
  has_many :questions, class_name: 'SurveyQuestion', inverse_of: :survey,
                       dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true,
                                            reject_if: :all_blank

  # The responses to this survey.
  has_many :responses, class_name: 'SurveyResponse', inverse_of: :survey,
      dependent: :destroy

  # True if the given user has responded to this survey.
  def answered_by?(user)
    !!responses.where(user: user).first
  end

  # True if the given user is allowed to see or respond to this survey.
  #
  # An equivalent method with the same name must be defined for Assignment so
  # the method can be called on either class.
  def can_submit?(user)
    (released? && course.is_student?(user)) || course.can_edit?(user)
  end

  # True if the given user is allowed to change or delete this survey.
  def can_edit?(user)
    course.can_edit? user
  end

  def can_delete?(user)
    return true if user && user.admin?
    (!released? || responses.empty?) && can_edit?(user)
  end
end
