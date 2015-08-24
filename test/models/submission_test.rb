require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    @submission = Submission.new deliverable: deliverables(:assessment_code),
        subject: users(:deedee), db_file: db_files(:deedee_code)
  end

  let(:submission) { submissions(:dexter_assessment) }
  let(:deliverable) { submission.deliverable }
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

  describe 'HasDbFile concern' do
    it 'requires a database-backed file' do
      @submission.db_file = nil
      assert @submission.invalid?
    end

    it 'forbids multiple submissions from using the same file in the database' do
      @submission.db_file = submission.db_file
      assert @submission.invalid?
    end

    it 'validates associated database-backed files' do
      db_file = @submission.build_db_file
      assert_equal false, db_file.valid?
      assert_equal false, @submission.valid?
    end

    describe '#file_name' do
      it 'returns the name of the uploaded file' do
        assert_equal 'dexter_assessment.pdf', submission.file_name
      end

      it 'returns nil if no file has been uploaded' do
        submission.db_file = nil
        assert_nil submission.file_name
      end
    end

    describe '#contents' do
      it 'returns the contents of the uploaded file' do
        path = File.join ActiveSupport::TestCase.fixture_path, 'submission_files',
            'small.pdf'
        assert_equal File.binread(path), submission.contents
      end

      it 'returns nil if no file has been uploaded' do
        submission.db_file = nil
        assert_nil submission.contents
      end
    end
  end

  it 'destroys dependent records' do
    assert_not_nil submission.db_file
    assert_not_nil submission.analysis
    assert_equal true, submission.collaborations.any?

    submission.destroy

    assert_nil DbFile.find_by(id: submission.db_file_id)
    assert_nil Analysis.find_by(submission: submission)
    assert_empty submission.collaborations.reload
  end

  it 'saves the associated db-file through the parent submission' do
    attachment = fixture_file_upload 'submission_files/good_fib.py',
        'application/x-python', :binary
    @submission.update! db_file_attributes: { f: attachment }

    assert_equal File.size(@submission.db_file.f.to_io),
        @submission.db_file.f_file_size
    assert_equal 'application/x-python', @submission.db_file.f_content_type
    path = File.join ActiveSupport::TestCase.fixture_path, 'submission_files',
        'good_fib.py'
    assert_equal File.binread(path), @submission.db_file.f.file_contents
  end

  describe '#can_read?' do
    it 'forbids non-author students from viewing a submission' do
      assert_equal true, submission.can_read?(student_author)
      assert_equal true, submission.can_read?(users(:robot))
      assert_equal true, submission.can_read?(users(:main_grader))
      assert_equal true, submission.can_read?(users(:main_staff))
      assert_equal true, submission.can_read?(users(:admin))
      assert_equal false, submission.can_read?(student_not_author)
      assert_equal false, submission.can_read?(nil)
    end
  end

  describe '#can_delete?' do
    it 'lets only the author or an admin delete a submission' do
      assert_equal true, submission.can_delete?(student_author)
      assert_equal false, submission.can_delete?(users(:robot))
      assert_equal false, submission.can_delete?(users(:main_grader))
      assert_equal false, submission.can_delete?(users(:main_staff))
      assert_equal true, submission.can_delete?(users(:admin))
      assert_equal false, submission.can_delete?(student_not_author)
      assert_equal false, submission.can_delete?(nil)
    end
  end

  describe '#can_edit?' do
    it 'lets only the author, staff, or admin edit submission metadata' do
      assert_equal true, submission.can_edit?(student_author)
      assert_equal false, submission.can_edit?(users(:robot))
      assert_equal false, submission.can_edit?(users(:main_grader))
      assert_equal true, submission.can_edit?(users(:main_staff))
      assert_equal true, submission.can_edit?(users(:admin))
      assert_equal false, submission.can_edit?(student_not_author)
      assert_equal false, submission.can_edit?(nil)
    end
  end

  describe '#can_collaborate?' do
    it 'lets students in the submission course collaborate' do
      assert_includes users(:deedee).registered_courses, submission.course
      assert_equal true, submission.can_collaborate?(users(:deedee))
    end

    it 'lets staff members of the submission course collaborate' do
      assert_equal true, submission.course.is_staff?(users(:main_staff))
      assert_equal true, submission.can_collaborate?(users(:main_staff))
    end

    it 'forbids non-student/non-staff users to collaborate' do
      assert_not_includes users(:inactive).registered_courses, submission.course
      assert_equal false, submission.course.is_staff?(users(:inactive))
      assert_equal false, submission.can_collaborate?(users(:inactive))
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

  describe '#copy_collaborators_from_previous_submission' do
    describe 'user does not have existing submissions for the deliverable' do
      it 'does not change the submission collaborators' do
        assert_empty Submission.where(subject: @submission.subject,
                                      deliverable: @submission.deliverable)
        @submission.copy_collaborators_from_previous_submission
        assert_empty @submission.collaborators.reload
      end
    end

    describe 'user has existing submissions for the deliverable' do
      it 'uses the collaborators of the previous submission' do
        previous_submission = deliverable.submissions.
            where(subject: student_author).last
        assert_equal [users(:deedee)].to_set,
            previous_submission.collaborators.to_set

        new_submission = deliverable.submissions.build subject: student_author
        new_submission.copy_collaborators_from_previous_submission
        assert_equal [users(:deedee)].to_set,
            new_submission.collaborators.to_set
      end
    end
  end
end
