# == Schema Information
# Schema version: 20100216020942
#
# Table name: feedback_question_sets
#
#  id         :integer(4)      not null, primary key
#  name       :string(128)     not null
#  created_at :datetime
#  updated_at :datetime
#

# A set of questions to be used for getting feedback on assignments.
#
# It's expected that many assignments will use the same set of questions, e.g.
# all psets would use one set of questions, and all projects will use another
# set of questions. Therefore, 
class FeedbackQuestionSet < ActiveRecord::Base
  # A name for the question set. Visible to admins.
  validates_length_of :name, :in => 1..128, :allow_nil => false
  
  # Memberships for the questions in this set.
  has_many :memberships, :class_name => 'FeedbackQuestionSetMembership',
                         :dependent => :destroy
  # The questions in this set.
  has_many :questions, :through => :memberships, :source => :feedback_question
end
