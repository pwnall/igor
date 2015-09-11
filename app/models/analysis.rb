# == Schema Information
#
# Table name: analyses
#
#  id            :integer          not null, primary key
#  submission_id :integer          not null
#  status_code   :integer          not null
#  score         :integer
#  log           :text             not null
#  private_log   :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# The result of analyzing a Submission.
class Analysis < ActiveRecord::Base
  # The submission that was analyzed.
  belongs_to :submission, inverse_of: :analysis
  validates :submission, presence: true, uniqueness: true

  # Grading advice produced by the analyzer.
  #
  # This attribute does not currently serve a purpose.
  validates :score, numericality: { integer_only: true,
      greater_than_or_equal_to: 0, allow_nil: true }

  # The analyzer's public logging output. This is shown to students.
  LOG_LIMIT = 64.kilobytes
  validates :log, length: { in: 0..LOG_LIMIT, allow_nil: false }

  # The analyzer's private logging output. This is only shown to staff.
  validates :private_log, length: { in: 0..LOG_LIMIT, allow_nil: false }

  # The course whose submission was analyzed.
  has_one :course, through: :submission

  # The user or team who created the submission being analyzed.
  has_one :subject, through: :submission

  # True if the given user is allowed to see the analysis.
  def can_read?(user)
    submission.can_read? user
  end

  # True if the given user is allowed to see the analyzer's private log.
  def can_read_private_log?(user)
    course.can_edit? user
  end
end

# :nodoc: Analysis life cycle.
class Analysis
  # Analysis status, can be one of the following symbols.
  enum status_code: {
    analyzer_bug: 1,     # The analyzer script crashed.
    queued: 2,           # Submission queued for analysis.
    running: 3,          # Submission is processed by an analyzer.
    limit_exceeded: 4,   # The analyzer consumed too many resources.
    crashed: 5,          # The submission crashed the analyzer.
    wrong: 6,            # The submission was analyzed to be incorrect.
    ok: 7,               # The submission seems correct.
    undefined: 8         # A safety net to catch invalid status code values.
  }
  validates_each :status_code do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.undefined?
      record.errors.add attr, 'was not valid'
    end
  end

  # The status of the analysis (virtual attribute).
  def status
    status_code.to_sym
  end

  # Set the status of the analysis (virtual attribute).
  def status=(new_status)
    begin
      self.status_code = new_status
    rescue ArgumentError
      self.status_code = :undefined
    end
  end

  # True if the submission's analysis is in progress.
  #
  # This is a hint for any UI that displays this analysis. If this method
  # returns true, the UI might choose to poll the database and refresh itself.
  def status_will_change?
    queued? || running?
  end

  # True if the analyzer ran and the submission was not rejected.
  def submission_ok?
    ok? || analyzer_bug?
  end

  # True if the submission is definitely incorrect.
  def submission_rejected?
    wrong? || crashed? || limit_exceeded?
  end
end

class Analysis
  # Resets all the data in the analysis.
  def reset_status!(new_status)
    self.status = new_status
    self.log = ''
    self.private_log = ''
    self.score = nil
    self.save!
  end

  # Resets the analysis data to reflect an internal exception.
  def record_exception(exception)
    self.status = :analyzer_bug
    self.log = ''
    self.private_log = <<ENDS
The analyzer code raised the exception below.

#{exception.class.name}: #{exception.message}
#{exception.backtrace.join("\n")}
ENDS
    self.score = nil
    self.save!
  end
end
