module OfflineTasks
  def self.validate_submission(submission)
    SubmissionValidator.delay.validate submission
  end
end
