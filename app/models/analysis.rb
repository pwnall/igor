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
  validates :submission, presence: true
  validates :submission_id, uniqueness: true

  # Grading advice produced by the analyzer.
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
    user.admin?
  end
end

# :nodoc: Analysis life cycle.
class Analysis
  # Analysis status, can be one of the following symbols.
  STATUS_CODES = {
    no_analyzer: 1,      # Submission's deliverable doesn't have an analyzer.
    queued: 2,           # Submission queued for analysis.
    running: 3,          # Submission is processed by an analyzer.
    limit_exceeded: 4,   # The analyzer consumed too many resources.
    crashed: 5,          # The analyzer crashed.
    wrong: 6,            # The submission was analyzed to be incorrect.
    ok: 7                # The submission seems correct.
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

  # True the submission appears to be correct.
  def submission_ok?
    status == :ok || status == :no_analyzer
  end

  # True if the submission is definitely incorrect.
  def submission_rejected?
    status == :wrong || status == :crashed || status == :limit_exceeded
  end
end

class Analysis
  # Resets all the data in the analyzer.
  def reset_status!(new_status)
    self.status = new_status
    self.log = ''
    self.private_log = ''
    self.score = nil
    self.save!
  end
end
