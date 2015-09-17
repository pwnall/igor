# A background job to analyze a student's submission.
class SubmissionAnalysisJob < ActiveJob::Base
  queue_as :default

  # Update the submission's analysis to reflect its queued status.
  before_enqueue do |job|
    job.arguments.first.analysis_queued!
  end

  # Update the submission's analysis to reflect its running status.
  before_perform do |job|
    job.arguments.first.analysis_running!
  end

  # Analyze the given submission.
  def perform(submission)
    begin
      submission.analyzer.analyze submission
    rescue StandardError => e
      submission.analysis.record_exception e

      # NOTE: Re-raising the exception has a few benefits. In development, it
      #       facilitates debugging. In production, it lets delayed_job use
      #       its retrying mechanics, which can get us past transient errors
      #       such as Docker being down, or the system getting rebooted.
      raise e
    end
  end
end