# == Schema Information
#
# Table name: analyses
#
#  id            :integer(4)      not null, primary key
#  submission_id :integer(4)      not null
#  score         :integer(4)
#  log           :text(16777215)  default(""), not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  status_code   :integer(4)      not null
#

# The result of analyzing a Submission. 
class Analysis < ActiveRecord::Base
  # Analyses aren't editable from Web forms.
  attr_accessible

  # The submission that was analyzed.
  belongs_to :submission, inverse_of: :analysis
  validates :submission, presence: true
  validates :submission_id, uniqueness: true

  # Grading advice produced by the analyzer.
  validates :score, numericality: { integer_only: true,
      greater_than_or_equal_to: 0, allow_nil: true }
  
  # The analyzer's logging output.
  validates :log, length: { in: 0..64.kilobytes, allow_nil: false }
end

# :nodoc: Analysis life cycle.
class Analysis
  # Analysis status, can be one of the following symbols.
  STATUS_CODES = {
    :no_analyzer => 1,      # Submission's deliverable doesn't have an analyzer.
    :queued => 2,           # Submission queued for analysis.
    :running => 3,          # Submission is processed by an analyzer.
    :limit_exceeded => 4,   # The analyzer consumed too many resources. 
    :crashed => 5,          # The analyzer crashed.
    :wrong => 6,            # The submission was analyzed to be incorrect.
    :ok => 7                # The submission seems correct.
  }.freeze
  STATUS_SYMBOLS = STATUS_CODES.invert.freeze
  validates :status_code, presence: true, inclusion: { in: STATUS_CODES.values }                          
  
  # :nodoc: synthetic attribute converting status to status_code
  def status=(new_status)
    new_status_code = STATUS_CODES[new_status]
    raise ArgumentError, "Invalid status #{new_status}" unless new_status_code
    self.status_code = new_status_code
  end
  def status
    STATUS_SYMBOLS[status_code]
  end
  
  # True if the submission's analysis is in progress.
  #
  # This is a hint for any UI that displays this analysis. If this method
  # returns true, the UI might choose to poll the database and refresh itself. 
  def status_will_change?
    status == :queued || status == :running
  end
end

class Analysis
  # Resets all the data in the analyzer.
  def reset_status!(new_status)
    self.status = new_status
    self.log = ''
    self.score = nil
    self.save!
  end  
end
