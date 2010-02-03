# == Schema Information
# Schema version: 18
#
# Table name: grades
#
#  id                   :integer(4)      not null, primary key
#  assignment_metric_id :integer(4)
#  user_id              :integer(4)
#  grader_user_id       :integer(4)
#  score                :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#

class Grade < ActiveRecord::Base
  belongs_to :assignment_metric
  belongs_to :user
  belongs_to :grader_user, :class_name => 'User'
end
