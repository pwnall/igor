# == Schema Information
#
# Table name: survey_questions
#
#  id              :integer          not null, primary key
#  survey_id       :integer          not null
#  prompt          :string(1024)     not null
#  allows_comments :boolean          not null
#  type            :string(32)       not null
#  features        :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# A question in a survey.
class SurveyQuestion < ApplicationRecord
  # The survey using this question.
  belongs_to :survey, inverse_of: :questions
  validates :survey, presence: true

  # The user-visible question string.
  validates :prompt, length: { in: 1..(1.kilobyte), allow_nil: false }

  # True if the question asks for comments, asides from the numerical answer.
  validates :allows_comments, inclusion: { in: [true, false], allow_nil: false }

  # The features that are customized for each question type.
  store :features, coder: JSON

  # The answers submitted in response to this question.
  has_many :answers, class_name: 'SurveyAnswer', foreign_key: :question_id,
                     inverse_of: :question

  # True if the given user should be able to submit responses to this question.
  def can_answer?(user)
    (!!user && survey.released?) || survey.can_edit?(user)
  end
end
