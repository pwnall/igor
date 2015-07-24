require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  before do
    @submission = Submission.new deliverable: deliverables(:assessment_code),
        subject: users(:deedee), db_file: db_files(:deedee_code)
  end

  let(:submission) { submissions(:dexter_assessment) }
  let(:student_author) { submission.subject }
  let(:student_not_author) { users(:deedee) }

  let(:team_submission) { submissions(:admin_ps1) }
  let(:team_author) { team_submission.subject }

  it 'validates the setup submission' do
    assert @submission.valid?, @submission.errors.full_messages
  end

  it 'requires a submitter' do
    @submission.subject = nil
    assert @submission.invalid?
  end

  it 'requires a deliverable' do
    @submission.deliverable = nil
    assert @submission.invalid?
  end

  it 'allows a user to have at most one submission per deliverable' do
    @submission.deliverable = deliverables(:assessment_writeup)
    assert @submission.invalid?
  end

  it 'requires a database-backed file' do
    @submission.db_file = nil
    assert @submission.invalid?
  end

  it 'destroys dependent records' do
    assert_not_nil submission.db_file
    assert_not_nil submission.analysis

    submission.destroy

    assert_nil DbFile.find_by(id: submission.db_file_id)
    assert_nil Analysis.find_by(submission_id: submission.id)
  end

  it 'forbids multiple submissions from using the same file in the database' do
    @submission.db_file = submissions(:dexter_code).db_file
    assert @submission.invalid?
  end

  it 'saves the associated db-file through the parent submission' do
    attachment = fixture_file_upload 'submission_files/good_fib.py',
        'application/x-python', :binary
    @submission.update! db_file_attributes: { f: attachment }

    assert_equal File.size(@submission.db_file.f.to_io), @submission.db_file.f_file_size
    assert_equal 'application/x-python', @submission.db_file.f_content_type
    path = File.join ActiveSupport::TestCase.fixture_path, 'submission_files',
        'good_fib.py'
    assert_equal File.binread(path), @submission.db_file.f.file_contents
  end

  describe '#can_read?' do
    it 'lets only the author or an admin view a submission' do
      assert_equal true, submission.can_read?(student_author)
      assert_equal true, submission.can_read?(users(:admin))
      assert_equal false, submission.can_read?(student_not_author)
      assert_equal false, submission.can_read?(nil)
    end
  end

  describe '#queue_analysis' do
    describe 'submission has an analyzer' do
      it 'builds an analysis and queues the submission for analysis' do
        assert_not_nil submission.analyzer
        submission.update! analysis: nil

        assert_difference 'Delayed::Job.count' do
          submission.queue_analysis
        end
        assert_equal :queued, submission.reload.analysis.status
      end

      it 'analyzes the queued submission' do
        submission.queue_analysis

        assert_equal [1, 0], Delayed::Worker.new.work_off
        assert_equal :ok, submission.reload.analysis.status
      end
    end

    describe 'submission has no analyzer' do
      before do
        submission.deliverable.analyzer.destroy
      end

      it 'builds an analysis and sets the status to :no_analyzer' do
        assert_nil submission.analyzer
        submission.update! analysis: nil
        submission.queue_analysis

        assert_equal :no_analyzer, submission.reload.analysis.status
      end
    end
  end

  describe '#run_analysis' do
    describe 'submission has an analyzer' do
      it 'builds an analysis and analyzes the submission' do
        assert_not_nil submission.analyzer
        submission.update! analysis: nil
        submission.run_analysis

        assert_equal :ok, submission.reload.analysis.status
      end
    end

    describe 'submission has no analyzer' do
      before do
        submission.deliverable.analyzer.destroy
      end

      it 'builds an analysis and sets the status to :no_analyzer' do
        assert_nil submission.analyzer
        submission.update! analysis: nil
        submission.run_analysis

        assert_equal :no_analyzer, submission.reload.analysis.status
      end
    end
  end

  describe '#ensure_analysis_exists' do
    it 'builds an associated analysis if one does not exist' do
      assert_nil @submission.analysis
      @submission.save!
      @submission.ensure_analysis_exists
      assert_not_nil @submission.analysis
      assert_equal :queued, @submission.analysis.status
    end

    it 'does not change an existing analysis' do
      submission.analysis.update! status: :ok
      assert_equal :ok, submission.analysis.status
      submission.ensure_analysis_exists
      assert_equal :ok, submission.reload.analysis.status
    end
  end

  describe '#is_owner?' do
    it 'recognizes an individual author' do
      assert_equal true, submission.is_owner?(student_author)
      assert_equal false, submission.is_owner?(student_not_author)
    end

    it 'recognizes a team author' do
      assert_includes team_author.users, users(:dexter)
      assert_not_includes team_author.users, users(:deedee)
      assert_equal true, team_submission.is_owner?(users(:dexter))
      assert_equal false, team_submission.is_owner?(users(:deedee))
    end

    it 'raises an exception for unrecognized author types' do
      unrecognized_submission = Submission.new db_file: db_files(:deedee_code),
          subject: deliverables(:assessment_code),
          deliverable: deliverables(:assessment_code)

      assert_raises(RuntimeError) do
        unrecognized_submission.is_owner? student_author
      end
    end
  end
end