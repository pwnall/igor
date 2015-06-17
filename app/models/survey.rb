# == Schema Information
#
# Table name: surveys
#
#  id         :integer          not null, primary key
#  name       :string(128)      not null
#  published  :boolean          not null
#  course_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# The set of questions used in a survey.
class Survey < ActiveRecord::Base
  include HasDeadline

  # A name for the question set. Visible to admins.
  validates :name, length: 1..128

  # Whether the survey has been released and users can submit responses.
  validates :published, inclusion: { in: [true, false], allow_nil: false }

  # Memberships for the questions in this set.
  has_many :memberships, class_name: 'SurveyQuestionMembership',
                         dependent: :destroy

  # The questions in this set.
  has_many :questions, through: :memberships, source: :survey_question

  # The course in which this survey is administered.
  belongs_to :course, inverse_of: :surveys
  validates :course, presence: true

  # The given user's response for this survey.
  def answer_for(user)
    return nil unless user
    SurveyAnswer.find_by user: user, survey: self
  end
end
