# == Schema Information
#
# Table name: analyses
#
#  id            :integer          not null, primary key
#  submission_id :integer          not null
#  status_code   :integer          not null
#  log           :text             not null
#  private_log   :text             not null
#  scores        :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# The result of analyzing a Submission.
class Analysis < ApplicationRecord
  # The submission that was analyzed.
  belongs_to :submission, inverse_of: :analysis
  validates :submission, presence: true, uniqueness: true

  # Applies to both the private and the public log.
  LOG_LIMIT = 64.kilobytes

  # The analyzer's public logging output. This is shown to students.
  validates :log, length: { in: 0..LOG_LIMIT, allow_nil: false }

  # The analyzer's private logging output. This is only shown to staff.
  validates :private_log, length: { in: 0..LOG_LIMIT, allow_nil: false }

  # The scores produced by the analyzer.
  #
  # This is a Hash mapping metric names to normalized scores between 0 and 1.
  serialize :scores, JSON

  # :nodoc: Papers over logging edge cases.
  def log=(new_log)
    super Analysis.truncate_log(new_log)
  end

  # :nodoc: Papers over logging edge cases.
  def private_log=(new_private_log)
    super Analysis.truncate_log(new_private_log)
  end

  # The course whose submission was analyzed.
  has_one :course, through: :submission

  # The analyzer that produced this analysis.
  has_one :analyzer, through: :submission

  # The assignment that this analysis' submission is for.
  has_one :assignment, through: :submission

  # True if the given user is allowed to see the analysis.
  def can_read?(user)
    submission.can_read? user
  end

  # True if the given user is allowed to see the analyzer's private log.
  def can_read_private_log?(user)
    course.can_edit? user
  end

  # Handles edge cases in logging output.
  #
  # @param {String?} original_log raw logging output
  # @return {String} a value suitable for being saved
  def self.truncate_log(original_log)
    log = original_log
    log = '(no output)' if log.nil?
    if log.length > LOG_LIMIT
      log = log[0...(LOG_LIMIT - 16)] + "\n---\n(truncated)"
    end
    log
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
    self.scores = {}
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
    self.scores = {}
    self.save!
  end

  # Updates the grades database to reflect the analyzer's output.
  #
  # The grades are only saved if auto-grading is enabled and the submission is
  # done by a course student. Staff submissions, used for testing auto-graders,
  # do not modify the grade database.
  def commit_grades
    return unless will_commit_grades?

    grades = self.grades_for_scores scores
    Analysis.transaction do
      if submission.selected_for_grading?
        grades.each(&:save)
      end
    end
  end

  # True if the analyzer's output will be saved into the grades database.
  #
  # The analyzer's grades are not saved
  def will_commit_grades?
    analyzer.auto_grading? && course.is_graded_subject?(submission.subject)
  end

  # Converts a JSON dictionary of scores into an array of Grade models.
  #
  # @param [Hash<String, Number>] scores the scores produced by the analyzer
  # @return [Array<Grade>] grades that can be saved to commit the scores
  def grades_for_scores(scores)
    metrics = assignment.metrics
    subject = submission.subject

    grades = []
    scores.each do |metric_name, score_fraction|
      metric = metrics.where(name: metric_name).first
      next unless metric

      grade = metric.grade_for subject
      grade.score = score_fraction * metric.max_score
      grade.grader = User.robot
      next unless grade.valid?

      grades << grade
    end
    grades
  end
end
