require 'test_helper'

class SubmissionAnalysisJobTest < ActiveJob::TestCase
  before { submission.update! analysis: nil }

  let(:submission) { submissions(:dexter_ps1) }

  describe '.perform_later' do
    it 'sets the analysis status of queued submissions to :queued' do
      SubmissionAnalysisJob.perform_later submission
      assert_equal :queued, submission.analysis.reload.status
    end
  end
end
