# == Schema Information
# Schema version: 20100216020942
#
# Table name: assignment_feedbacks
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  assignment_id :integer(4)      not null
#  comments      :string(4096)
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
end
