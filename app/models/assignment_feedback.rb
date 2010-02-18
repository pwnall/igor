# == Schema Information
# Schema version: 20100216020942
#
# Table name: assignment_feedbacks
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  assignment_id :integer(4)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

# A user's feedback on an assignment.
class AssignmentFeedback < ActiveRecord::Base
  # The user providing the feedback.
  belongs_to :user
  
  # The subject of this feedback.
  belongs_to :assignment
    
  # The answers that are part of this feedback.
  has_many :answers, :class_name => 'FeedbackAnswer', :dependent => :destroy
  accepts_nested_attributes_for :answers
  
  # The questions asked for this feedback.
  def questions
    # NOTE: this should be a has_many :through association, but ActiveRecord
    #       doesn't support nested :through associations
    assignment.feedback_questions
  end
  
  # Creates empty answers to all the questions in this feedback.
  def create_answers
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
end
