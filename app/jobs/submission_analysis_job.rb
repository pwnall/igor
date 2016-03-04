# A background job to analyze a student's submission.
class SubmissionAnalysisJob < ApplicationJob
  queue_as :default

  # Update the submission's analysis to reflect its queued status.
  before_enqueue do |job|
    arguments.first.analysis_queued!
  end

  # Update the submission's analysis to reflect its running status.
  before_perform do |job|
    if submission = arguments.first
      submission.analysis_running!
    end
  end

  # Update the submission's analysis to reflect an internal exception.
  rescue_from(StandardError) do |exception|
    # NOTE: The submission can be deleted by the time the queued job gets run.
    if submission = arguments.first
      submission.analysis.record_exception exception
    end

    # NOTE: Re-raising the exception has a few benefits. In development, it
    #       facilitates debugging. In production, it lets delayed_job use
    #       its retrying mechanics, which can get us past transient errors
    #       such as Docker being down, or the system getting rebooted.
    raise exception
  end

  # Analyze the given submission.
  def perform(submission)
    # NOTE: The submission can be deleted by the time the queued job gets run.
    if submission
      submission.analyzer.analyze submission
      submission.analysis.commit_grades
    end
  end
end
