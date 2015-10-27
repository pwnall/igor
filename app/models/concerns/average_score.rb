require 'active_support'

# Calculations handling scores on Assignments and AssignmentMetrics.
module AverageScore
  extend ActiveSupport::Concern

  included do
    # The average score converted to a number out of 100.
    def average_score_percentage
      return nil if respond_to?(:metrics) && metrics.empty?
      return 0 if max_score.zero?
      average_score * 100 / max_score.to_f
    end
  end
end
