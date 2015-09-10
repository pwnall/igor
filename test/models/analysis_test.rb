require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  before do
    @analysis = Analysis.new submission: submissions(:solo_ps1),
        status: :queued, log: '', private_log: ''
  end

  let(:analysis) { analyses(:dexter_assessment) }
  let(:student_author) { analysis.submission.subject }
  let(:student_not_author) { users(:deedee) }

  it 'validates the setup analysis' do
    assert @analysis.valid?, @analysis.errors.full_messages
  end

  it 'requires a submission' do
    @analysis.submission = nil
    assert @analysis.invalid?
  end

  it 'forbids a submission from having more than one analysis' do
    @analysis.submission = analysis.submission
    assert @analysis.invalid?
  end

  it 'truncates non-integer scores' do
    @analysis.score = 1.9
    assert_equal 1, @analysis.score
  end

  it 'rejects negative scores' do
    @analysis.score = -1
    assert @analysis.invalid?
  end

  it 'requires a log' do
    @analysis.log = nil
    assert @analysis.invalid?
  end

  it 'rejects lengthy logs' do
    @analysis.log = 'l' * (Analysis::LOG_LIMIT + 1)
    assert @analysis.invalid?
  end

  it 'requires a private log' do
    @analysis.private_log = nil
    assert @analysis.invalid?
  end

  it 'rejects lengthy private logs' do
    @analysis.private_log = 'l' * (Analysis::LOG_LIMIT + 1)
    assert @analysis.invalid?
  end

  describe '#can_read?' do
    it 'forbids non-author students from viewing an analysis' do
      assert_equal true, analysis.can_read?(student_author)
      assert_equal true, analysis.can_read?(users(:robot))
      assert_equal true, analysis.can_read?(users(:main_grader))
      assert_equal true, analysis.can_read?(users(:main_staff))
      assert_equal true, analysis.can_read?(users(:admin))
      assert_equal false, analysis.can_read?(student_not_author)
      assert_equal false, analysis.can_read?(nil)
    end
  end

  describe '#can_read_private_log?' do
    it 'lets only course/site admins view the private log' do
      assert_equal false, analysis.can_read_private_log?(student_author)
      assert_equal false, analysis.can_read_private_log?(users(:robot))
      assert_equal false, analysis.can_read_private_log?(users(:main_grader))
      assert_equal true, analysis.can_read_private_log?(users(:main_staff))
      assert_equal true, analysis.can_read_private_log?(users(:admin))
      assert_equal false, analysis.can_read_private_log?(student_not_author)
      assert_equal false, analysis.can_read_private_log?(nil)
    end
  end

  describe 'analysis life cycle' do
    it 'requires a status' do
      @analysis.status = nil
      assert @analysis.invalid?
    end

    describe '#status' do
      it 'returns the status code symbol' do
        assert_equal true, @analysis.queued?
        assert_equal :queued, @analysis.status
      end
    end

    describe '#status=' do
      it 'sets the status code' do
        assert_equal true, @analysis.queued?
        @analysis.status = :ok
        assert_equal true, @analysis.ok?
      end

      it 'rejects invalid statuses' do
        @analysis.status = :not_a_status_code
        assert @analysis.invalid?
      end
    end

    describe '#status_will_change?' do
      it 'returns true if the analysis is queued' do
        analysis.queued!
        assert_equal true, analysis.status_will_change?
      end

      it 'returns true if the analysis is running' do
        analysis.running!
        assert_equal true, analysis.status_will_change?
      end

      it 'returns false if the analysis is not queued or running' do
        analysis.ok!
        assert_equal false, analysis.status_will_change?
      end
    end

    describe '#submission_ok?' do
      it 'returns true if the submission passed' do
        analysis.ok!
        assert_equal true, analysis.submission_ok?
      end

      it 'returns true if the analyzer script was buggy' do
        analysis.analyzer_bug!
        assert_equal true, analysis.submission_ok?
      end

      it 'returns false if the analysis did not finish or pass' do
        analysis.running!
        assert_equal false, analysis.submission_ok?
      end
    end

    describe '#submission_rejected?' do
      it 'returns true if the submission was incorrect' do
        analysis.wrong!
        assert_equal true, analysis.submission_rejected?
      end

      it 'returns true if the analyzer crashed' do
        analysis.crashed!
        assert_equal true, analysis.submission_rejected?
      end

      it 'returns true if the submission timed out' do
        analysis.limit_exceeded!
        assert_equal true, analysis.submission_rejected?
      end

      it 'returns false if the submission was not rejected' do
        analysis.running!
        assert_equal false, analysis.submission_rejected?
      end
    end
  end

  describe '#reset_status!' do
    it 'resets all the analysis data' do
      analysis.update! status: :queued, log: 'log', private_log: 'private',
                       score: 1
      analysis.reset_status! :running
      analysis.reload

      assert_equal :running, analysis.status
      assert_equal '', analysis.log
      assert_equal '', analysis.private_log
      assert_nil analysis.score
    end
  end
end
