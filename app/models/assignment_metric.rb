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

  # True if the given user should be allowed to see the metric.
  def visible_for?(user)
    assignment.metrics_ready? || (user && user.admin?)
  end
  
  # True if this metric can be destroyed without a warning.
  def safe_to_destroy?
    grades.empty?
  end
end

# == Schema Information
#
# Table name: assignment_metrics
#
#  id            :integer(4)      not null, primary key
#  name          :string(64)      not null
#  assignment_id :integer(4)      not null
#  max_score     :integer(4)
#  published     :boolean(1)      default(FALSE)
#  weight        :decimal(16, 8)  default(1.0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

