# == Schema Information
# Schema version: 20100216020942
#
# Table name: feedback_question_set_memberships
#
#  id                       :integer(4)      not null, primary key
#  feedback_question_id     :integer(4)      not null
#  feedback_question_set_id :integer(4)      not null
#  created_at               :datetime
#

# Connects assignment feedback questions to the sets that they belong to.
class FeedbackQuestionSetMembership < ActiveRecord::Base
  # The question that belongs to a set.
  belongs_to :feedback_question
  
  # The set that the question belongs to.
  belongs_to :feedback_question_set
end
