# == Schema Information
#
# Table name: grades
#
#  id           :integer(4)      not null, primary key
#  metric_id    :integer(4)      not null
#  grader_id    :integer(4)      not null
#  subject_id   :integer(4)      not null
#  subject_type :string(64)
#  score        :decimal(8, 2)   not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Grade < ActiveRecord::Base
  # The metric that this grade is for.
  belongs_to :metric, class_name: 'AssignmentMetric'
  validates :metric, presence: true
  validates :metric_id, uniqueness: { scope: [:subject_id, :subject_type] }
  
  # The subject being graded (a user or a team).
  belongs_to :subject, polymorphic: true
  validates :subject, presence: true
  
  # The user who posted this grade (an admin).
  belongs_to :grader, class_name: 'User'
  validates :grader, presence: true

  # The numeric grade.
  validates_numericality_of :score, :only_integer => false
  
  # The users impacted by a grade.
  def users
    subject.respond_to?(:users) ? subject.users : [subject]
  end
end
