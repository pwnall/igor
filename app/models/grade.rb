# == Schema Information
# Schema version: 20100216020942
#
# Table name: grades
#
#  id                   :integer(4)      not null, primary key
#  assignment_metric_id :integer(4)      not null
#  subject_type         :string(64)      not null
#  subject_id           :integer(4)      not null
#  grader_id            :integer(4)      not null
#  score                :decimal(8, 2)   not null
#  created_at           :datetime
#  updated_at           :datetime
#

class Grade < ActiveRecord::Base
  # The metric that this grade is for.
  belongs_to :assignment_metric
  validates_presence_of :assignment_metric
  
  # The subject being graded (a user or a team).
  belongs_to :subject, :polymorphic => true
  validates_presence_of :subject
  
  # The user who posted this grade (an admin).
  belongs_to :grader, :class_name => 'User'
  validates_presence_of :grader

  # The numeric grade.
  validates_numericality_of :score, :only_integer => false
end
