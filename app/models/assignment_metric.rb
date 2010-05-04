# == Schema Information
# Schema version: 20100504203833
#
# Table name: assignment_metrics
#
#  id            :integer(4)      not null, primary key
#  name          :string(64)      not null
#  assignment_id :integer(4)      not null
#  max_score     :integer(4)
#  published     :boolean(1)
#  weight        :decimal(16, 8)  default(1.0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

# A measurable (and measured) result of an assignment.
#
# For example, "the score for Problem 1".
class AssignmentMetric < ActiveRecord::Base
  # The assignment that this metric is for.
  belongs_to :assignment  
  validates_presence_of :assignment
  
  # The grades issued for this metric.
  has_many :grades, :foreign_key => :metric_id
  
  # The maximum score (grade) that can be received on this metric.
  #
  # This score is for display purposes, and it is not enforced.
  #
  # This decision was taken to allow for "bonus" points, e.g. a score of 11 out
  # of 10 for excellent work  
  validates_numericality_of :max_score, :allow_nil => false, :greater_than => 0

  # If true, non-admins can see this metric, as well as their scores on it.
  validates_inclusion_of :published, :in => [true, false]
  
  # The metric's weight when computing total class scores.
  #
  # This is computed manually by the admins, by taking into account each
  # assignment's maximum score, as well as its weight in the final class grade.
  # For example, exam scores usually weigh heavier than pset scores.
  validates_numericality_of :weight, :in => [true, false]
  
  # True if the given user should be allowed to see the metric.
  def visible_for_user?(user)
    published? or (user and user.admin?)
  end
end
