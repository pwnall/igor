# == Schema Information
# Schema version: 20100216020942
#
# Table name: feedback_answers
#
#  id                     :integer(4)      not null, primary key
#  assignment_feedback_id :integer(4)      not null
#  question_id            :integer(4)      not null
#  target_user_id         :integer(4)
#  number                 :float           not null
#  comment                :string(1024)
#  created_at             :datetime
#  updated_at             :datetime
#

# A piece of feedback. An answer to a question on a feedback form.
class FeedbackAnswer < ActiveRecord::Base  
  # The assignment feedback that this answer is a part of. 
  belongs_to :assignment_feedback  
  
  # The question that this answer corresponds to.
  belongs_to :question, :class_name => 'FeedbackQuestion'
  validates_presence_of :question, :allow_nil => false
  validates_uniqueness_of :question_id,
                          :scope => [:assignment_feedback_id]
  
  # The user that the feedback is about.
  #
  # Can be nil if the feedback is about an assignment.
  belongs_to :target_user, :class_name => 'User'

  # The numeric answer for the question.
  validates_numericality_of :number, :allow_nil => false

  # A comment on the rating meant for the course administrators.
  validates_length_of :comment, :in => 1..(1.kilobyte), :allow_nil => true

  # Nullify an empty comment.
  def comment=(new_comment)
    new_comment = nil if new_comment.empty?
    super new_comment
  end
end
