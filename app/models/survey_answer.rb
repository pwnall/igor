# == Schema Information
# Schema version: 20100427075741
#
# Table name: survey_answers
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  assignment_id :integer(4)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

# A user's response to a set of questions.
class SurveyAnswer < ActiveRecord::Base
  # The user responding to the survey.
  belongs_to :user
  
  # The subject of this feedback.
  # TODO(costan): make this polymorphic, rename to subject
  belongs_to :assignment
    
  # The answers that are part of this feedback.
  has_many :answers, :class_name => 'SurveyQuestionAnswer',
                     :dependent => :destroy
  accepts_nested_attributes_for :answers
  
  # The questions asked for this feedback.
  def questions
    # TODO(costan): when generalizing Survey, duplicate the survey_id in
    #               SurveyAnswer, to get the questions directly from there
    
    # NOTE: this should be a has_many :through association, but ActiveRecord
    #       doesn't support nested :through associations    
    assignment.feedback_questions
  end
  
  # Creates empty answers to all the questions in this feedback.
  def create_question_answers
    user_questions, global_questions = *questions.partition(&:targets_user?)
    global_questions.each do |question|
      answers.build :question => question
    end
    
    return answers unless assignment.team_partition
    unless teammates = assignment.team_partition.teammates_for_user(user)
      return answers
    end
    
    teammates.each do |teammate|
      user_questions.each do |question|
        answers.build :question => question, :target_user => teammate
      end
    end
    answers
  end
  
  # The assignments that a user can choose from for completing feedback surveys.
  def self.assignments_for_user(user)
    # TODO(costan): this should be renamed to subjects_for_user
    assignments = Assignment.all.select(&:feedback_survey_id)
    assignments = assignments.select(&:accepts_feedback?) unless user.admin?
    assignments
  end
end
