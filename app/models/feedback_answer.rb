# == Schema Information
# Schema version: 20100216020942
#
# Table name: feedback_answers
#
#  id                     :integer(4)      not null, primary key
#  assignment_feedback_id :integer(4)      not null
#  question_id            :integer(4)      not null
#  user_id                :integer(4)      not null
#  target_user_id         :integer(4)
#  number                 :float           not null
#  comment                :string(1024)    not null
#  created_at             :datetime
#  updated_at             :datetime
#

# A piece of feedback. An answer to a question on a feedback form.
class FeedbackAnswer < ActiveRecord::Base
  # The question that this answer corresponds to.
  belongs_to :feedback_question
  validates_presence_of :feedback_question, :allow_nil => false
  
  # The assignment feedback that this answer is a part of. 
  belongs_to :assignment_feedback  
  validates_presence_of :assignment_feedback, :allow_nil => false
  
  # The user providing the feedback.
  belongs_to :user
  validates_presence_of :user, :allow_nil => false
  validates_uniqueness_of :user_id,
      :scope => [:assignment_feedback_id, :feedback_question_id]

  # The user that the feedback is about.
  #
  # Can be nil if the feedback is about an assignment.
  belongs_to :target_user

  # The numeric answer for the question.
  validates_numericality_of :number, :allow_nil => false

  # A comment on the rating meant for the course administrators.
  validates_length_of :comment, :in => 0..(1.kilobyte), :allow_nil => false
end
