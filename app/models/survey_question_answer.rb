# == Schema Information
#
# Table name: survey_question_answers
#
#  id               :integer          not null, primary key
#  survey_answer_id :integer          not null
#  question_id      :integer          not null
#  target_user_id   :integer
#  number           :float            not null
#  comment          :string(1024)
#  created_at       :datetime
#  updated_at       :datetime
#

# An answer to a question in a survey.
class SurveyQuestionAnswer < ActiveRecord::Base  
  # The survey answer that this question answer is a part of. 
  belongs_to :survey_answer
  
  # The question that this answer corresponds to.
  belongs_to :question, class_name: 'SurveyQuestion'
  validates_presence_of :question, allow_nil: false
  validates_uniqueness_of :question_id, scope: [:survey_answer_id]
  
  # The user that the feedback is about.
  #
  # Can be nil if the feedback is about an assignment.
  belongs_to :target_user, class_name: 'User'

  # The numeric answer for the question.
  validates_numericality_of :number, allow_nil: false

  # A comment on the rating meant for the course administrators.
  validates_length_of :comment, in: 1..(1.kilobyte), allow_nil: true

  # Nullify an empty comment.
  def comment=(new_comment)
    new_comment = nil if new_comment.empty?
    super new_comment
  end
end
