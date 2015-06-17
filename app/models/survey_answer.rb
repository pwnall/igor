# == Schema Information
#
# Table name: survey_answers
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  survey_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A user's response to a set of questions.
class SurveyAnswer < ActiveRecord::Base
  # The user responding to the survey.
  belongs_to :user, inverse_of: :survey_answers
  validates :user, presence: true

  belongs_to :survey, inverse_of: :survey_answers
  validates :survey, uniqueness: { scope: :user_id }, presence: true

  # The answers that are part of this feedback.
  has_many :answers, -> { order(:target_user_id, :question_id) },
      class_name: 'SurveyQuestionAnswer', dependent: :destroy
  accepts_nested_attributes_for :answers

  # The questions asked for this feedback.
  def questions
    # TODO(costan): when generalizing Survey, duplicate the survey_id in
    #               SurveyAnswer, to get the questions directly from there

    # NOTE: this should be a has_many :through association, but ActiveRecord
    #       doesn't support nested :through associations
    survey.questions
  end

  # Creates empty answers to all the questions in this feedback.
  def create_question_answers
    user_questions, global_questions = *questions.partition(&:targets_user?)
    global_questions.each do |question|
      answers.build question: question
    end

    return answers unless assignment.team_partition
    unless teammates = assignment.team_partition.teammates_for_user(user)
      return answers
    end

    teammates.each do |teammate|
      user_questions.each do |question|
        answers.build question: question, target_user: teammate
      end
    end
    answers
  end
end
