# == Schema Information
# Schema version: 20110208012638
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
  belongs_to :assignment, :inverse_of => :metrics
  validates :assignment, :presence => true
  
  # The grades issued for this metric.
  has_many :grades, :foreign_key => :metric_id
  
  # The user-friendly name for this metric.
  validates :name, :length => 1..64, :presence => true,
                   :uniqueness => { :scope => [:assignment_id] }
  
  # The maximum score (grade) that can be received on this metric.
  #
  # This score is for display purposes, and it is not enforced.
  #
  # This decision was taken to allow for "bonus" points, e.g. a score of 11 out
  # of 10 for excellent work  
  validates :max_score, :numericality => { :greater_than => 0 },
                        :presence => true

  # If true, non-admins can see this metric, as well as their scores on it.
  validates :published, :inclusion => { :in => [true, false],
                                        :allow_nil => false }
  
  # The metric's weight when computing total class scores.
  #
  # This is computed manually by the admins, by taking into account each
  # assignment's maximum score, as well as its weight in the final class grade.
  # For example, exam scores usually weigh heavier than pset scores.
  validates :weight, :numericality => true
  
  # True if the given user should be allowed to see the metric.
  def visible_for?(user)
    published? or (user and user.admin?)
  end
end
