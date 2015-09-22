require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    @submission = Submission.new deliverable: deliverables(:assessment_code),
        uploader: users(:deedee), db_file: db_files(:deedee_code)
  end

  let(:submission) { submissions(:dexter_assessment) }
  let(:analysis) { submission.analysis }
  let(:deliverable) { submission.deliverable }
  let(:student_author) { submission.subject }
  let(:student_not_author) { users(:deedee) }

  let(:team_submission) { submissions(:dexter_ps1) }
  let(:team_author) { team_submission.subject }

  it 'validates the setup submission' do
    assert @submission.valid?, @submission.errors.full_messages
  end

  it 'requires an uploader' do
    @submission.uploader = nil
    assert @submission.invalid?
  end

  it 'requires a subject' do
    @submission.subject = nil
    assert @submission.invalid?
  end

  it 'requires a deliverable' do
    @submission.deliverable = nil
    assert @submission.invalid?
  end

  it 'rejects inconsistencies between uploader and subject' do
    @submission.subject = users(:dexter)
    assert @submission.invalid?
  end

  describe '#uploader=' do
    it 'handles nil' do
      @submission.uploader = nil
      assert_equal nil, @submission.subject
    end

    it 'handles a student' do
      @submission.uploader = users(:dexter)
      assert_equal users(:dexter), @submission.subject
    end
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

  describe '#analysis_queued!' do
    describe 'submission does not have an analysis' do
      it 'creates a blank analysis with status :queued' do
        assert_nil @submission.analysis
        assert_difference 'Analysis.count' do
          @submission.analysis_queued!
        end
        assert_equal :queued, @submission.analysis.reload.status
        assert_equal '', @submission.analysis.log
        assert_equal '', @submission.analysis.private_log
      end
    end

    describe 'submission has an analysis' do
      it 'resets the analysis with status :queued' do
        analysis.update! status: :wrong, log: 'log', private_log: 'private'
        assert_no_difference 'Analysis.count' do
          submission.analysis_queued!
        end
        assert_equal :queued, analysis.reload.status
        assert_equal '', analysis.log
        assert_equal '', analysis.private_log
      end
    end
  end

  describe '#analysis_running!' do
    describe 'submission does not have an analysis' do
      it 'creates a blank analysis with status :running' do
        assert_nil @submission.analysis
        assert_difference 'Analysis.count' do
          @submission.analysis_running!
        end
        assert_equal :running, @submission.analysis.reload.status
        assert_equal '', @submission.analysis.log
        assert_equal '', @submission.analysis.private_log
      end
    end

    describe 'submission has an analysis' do
      it 'resets the analysis with status :queued' do
        analysis.update! status: :wrong, log: 'log', private_log: 'private'
        assert_no_difference 'Analysis.count' do
          submission.analysis_running!
        end
        assert_equal :running, analysis.reload.status
        assert_equal '', analysis.log
        assert_equal '', analysis.private_log
      end
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
