# == Schema Information
#
# Table name: analyses
#
#  id            :integer(4)      not null, primary key
#  submission_id :integer(4)      not null
#  score         :integer(4)
#  diagnostic    :string(256)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  log           :text(16777215)
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
  validates :log, length: { in: 1..64.kilobytes, allow_nil: true }

  # Analysis status, can be one of the following symbols.
  STATUS_SYMBOLS = {
    :no_analyzer => 1,
    :queued => 2,
    :running => 3,
    :limits_exceeded => 4,
    :crashed => 5,
    :wrong => 6,
    :ok => 7
  }.freeze
  STATUS_VALUES = STATUS_SYMBOLS.invert.freeze
  validates :raw_status, :inclusion => { :in => STATUS_SYMBOLS.values }
  
  # :nodoc: synthetic attribute converting status to raw_status
  def status=(new_status)
    new_raw_status = STATUS_VALUES[new_status]
    raise ArgumentError, "Invalid status #{new_status}" unless value
    self.raw_status = new_raw_status
  end
  def status
    STATUS_VALUES[raw_status]
  end
end

class Analysis
  # Resets all the data in the analyzer.
  def reset_status!(new_status)
    self.status = new_status
    self.log = self.score = nil
    self.save!
  end  
end
