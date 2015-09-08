# == Schema Information
#
# Table name: survey_answers
#
#  id          :integer          not null, primary key
#  question_id :integer          not null
#  response_id :integer          not null
#  number      :decimal(7, 2)
#  comment     :string(1024)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# An answer to a question in a survey.
class SurveyAnswer < ActiveRecord::Base
  # The survey question at which this response is directed.
  belongs_to :question, class_name: 'SurveyQuestion', inverse_of: :answers
  validates :question, presence: true, uniqueness: { scope: :response }

  # The response containing all of the student's answers to the survey.
  belongs_to :response, class_name: 'SurveyResponse', inverse_of: :answers,
                        foreign_key: :response_id
  validates_each :response do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.survey != value.survey
      record.errors.add attr, "does not match the question's survey"
    end
  end

  # The numeric answer for the question.
  validates :number, numericality: { greater_than_or_equal_to: 0,
      less_than: 10000000, allow_nil: true }

  # A comment on the rating meant for the course administrators.
  validates :comment, length: { in: 1..(1.kilobyte), allow_nil: true }

  # The survey containing the question.
  has_one :survey, through: :question

  # The course in which the question has been asked.
  has_one :course, through: :question

  # The author of the answer.
  has_one :user, through: :response

  # Nullify a blank comment.
  def comment=(new_comment)
    new_comment = nil if new_comment.blank?
    super new_comment
  end
end
