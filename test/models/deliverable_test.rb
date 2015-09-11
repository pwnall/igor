require 'test_helper'

class DeliverableTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.
  include ActiveJob::TestHelper

  before do
    @deliverable = Deliverable.new assignment: assignments(:ps1),
        file_ext: 'pdf', name: 'Extra Credit', description: 'Bonus for PS1',
        analyzer_attributes: { type: 'ProcAnalyzer', auto_grading: 0,
        message_name: 'analyze_pdf' }
  end

  let(:deliverable) { deliverables(:assessment_writeup) }
  let(:assignment) { deliverable.assignment }
  let(:student) { users(:dexter) }
  let(:any_user) { User.new }
  let(:admin) { users(:admin) }

  it 'validates the setup deliverable' do
    assert @deliverable.valid?
  end

  it 'requires a name' do
    @deliverable.name = nil
    assert @deliverable.invalid?
  end

  it 'rejects lengthy names' do
    @deliverable.name = 'n' * 65
    assert @deliverable.invalid?
  end

  it 'forbids deliverables for the same assignment from sharing names' do
    @deliverable.name = assignments(:ps1).deliverables.first.name
    assert @deliverable.invalid?
  end

  it 'requires a description' do
    @deliverable.description = nil
    assert @deliverable.invalid?
  end

  it 'rejects lengthy descriptions' do
    @deliverable.description = 'd' * (2.kilobytes + 1)
    assert @deliverable.invalid?
  end

  it 'requires a file extension' do
    @deliverable.file_ext = nil
    assert @deliverable.invalid?
  end

  it 'rejects lengthy file extensions' do
    @deliverable.file_ext = 'f' * 17
    assert @deliverable.invalid?
  end

  it 'requires an assignment' do
    @deliverable.assignment = nil
    assert @deliverable.invalid?
  end

  it 'destroys dependent records' do
    assert_not_nil deliverable.analyzer
    assert_equal true, deliverable.submissions.any?

    deliverable.destroy

    assert_nil Analyzer.find_by(deliverable: deliverable)
    assert_empty deliverable.submissions.reload
  end

  it 'requires an analyzer' do
    @deliverable.analyzer = nil
    assert @deliverable.invalid?
  end

  it 'validates an associated analyzer' do
    @deliverable.analyzer.message_name = nil
    assert_equal false, @deliverable.analyzer.valid?
    assert_equal false, @deliverable.valid?
  end

  it 'saves the associated ProcAnalyzer through the parent deliverable' do
    assert_instance_of ProcAnalyzer, @deliverable.analyzer
    assert_difference 'ProcAnalyzer.count' do
      @deliverable.save!
    end
  end

  it 'saves the associated ScriptAnalyzer through the parent deliverable' do
    @deliverable.analyzer = nil
    attachment = fixture_file_upload 'analyzer_files/fib.zip',
        'application/zip', :binary
    deliverable_params = { analyzer_attributes: {
      type: 'ScriptAnalyzer', auto_grading: 1, time_limit: 2, ram_limit: 1024,
      file_limit: 10, file_size_limit: 100, process_limit: 5,
      db_file_attributes: { f: attachment }
    } }

    assert_difference 'ScriptAnalyzer.count' do
      @deliverable.update! deliverable_params
    end
  end

  describe '#can_read?' do
    it 'lets any user view deliverable if :deliverables_ready is true' do
      deliverable.assignment.update! deliverables_ready: true
      assert_equal true, deliverable.can_read?(any_user)
      assert_equal true, deliverable.can_read?(nil)
    end

    it 'lets only admins view deliverable if :deliverables_ready is false' do
      deliverable.assignment.update! deliverables_ready: false
      assert_equal true, deliverable.can_read?(admin)
      assert_equal false, deliverable.can_read?(any_user)
      assert_equal false, deliverable.can_read?(nil)
    end
  end

  describe '#submission_for_grading' do
    describe 'individual assignments' do
      let(:individual_deliverable) { deliverables(:assessment_code) }
      let(:student) { users(:dexter) }

      it 'if the user has no submissions for this deliverable, returns nil' do
        Submission.where(deliverable: individual_deliverable,
                         subject: student).destroy_all

        assert_nil individual_deliverable.submission_for_grading(student)
        assert_nil individual_deliverable.submission_for_grading(nil)
      end

      it "returns the user's most recently updated submission" do
        earlier = submissions(:dexter_code)
        later = submissions(:dexter_code_v2)
        assert_operator earlier.updated_at, :<, later.created_at
        assert_equal later,
            individual_deliverable.submission_for_grading(student)

        earlier.touch
        assert_equal earlier,
            individual_deliverable.submission_for_grading(student)

        later.touch
        assert_equal later,
            individual_deliverable.submission_for_grading(student)
      end
    end

    describe 'team assignments' do
      let(:team_deliverable) { deliverables(:project_writeup) }
      let(:teammate) { users(:dexter) }
      let(:team) { teams(:awesome_project) }
      let(:earlier) { submissions(:dexter_project) }
      let(:later) { submissions(:dexter_project_v2) }

      it 'returns the latest team submission' do
        assert_operator earlier.updated_at, :<, later.created_at
        assert_equal later, team_deliverable.submission_for_grading(teammate)
        assert_equal later, team_deliverable.submission_for_grading(team)

        earlier.touch
        assert_equal earlier, team_deliverable.submission_for_grading(teammate)
        assert_equal earlier, team_deliverable.submission_for_grading(team)

        later.touch
        assert_equal later, team_deliverable.submission_for_grading(teammate)
        assert_equal later, team_deliverable.submission_for_grading(team)
      end
    end
  end

  describe '#submissions_for' do
    describe 'individual assignments' do
      let(:individual_deliverable) { deliverables(:assessment_code) }
      let(:student) { users(:dexter) }

      it 'if the user has no submissions for this deliverable, returns []' do
        Submission.where(deliverable: individual_deliverable,
                         subject: student).destroy_all

        assert_equal [], individual_deliverable.submissions_for(student).all
        assert_equal [], individual_deliverable.submissions_for(nil).all
      end

      it "returns the user's most recently updated submission" do
        earlier = submissions(:dexter_code)
        later = submissions(:dexter_code_v2)
        assert_operator earlier.updated_at, :<, later.created_at
        assert_equal [later, earlier],
            individual_deliverable.submissions_for(student).all

        earlier.touch
        assert_equal [earlier, later],
            individual_deliverable.submissions_for(student).all

        later.touch
        assert_equal [later, earlier],
            individual_deliverable.submissions_for(student).all
      end
    end

    describe 'team assignments' do
      let(:team_deliverable) { deliverables(:project_writeup) }
      let(:teammate) { users(:dexter) }
      let(:team) { teams(:awesome_project) }
      let(:earlier) { submissions(:dexter_project) }
      let(:later) { submissions(:dexter_project_v2) }

      it 'returns the latest team submission' do
        assert_operator earlier.updated_at, :<, later.created_at
        assert_equal [later, earlier],
            team_deliverable.submissions_for(teammate)
        assert_equal [later, earlier], team_deliverable.submissions_for(team)

        earlier.touch
        assert_equal [earlier, later],
            team_deliverable.submissions_for(teammate)
        assert_equal [earlier, later], team_deliverable.submissions_for(team)

        later.touch
        assert_equal [later, earlier],
            team_deliverable.submissions_for(teammate)
        assert_equal [later, earlier], team_deliverable.submissions_for(team)
      end
    end
  end

  describe '#expected_submissions' do
    it 'returns the number of students currently enrolled' do
      assert_equal 4, deliverable.expected_submissions
    end
  end

  describe '#reanalyze_submissions' do
    describe 'deliverable analyzer is a ProcAnalyzer' do
      it 'queues all submissions for reanalysis' do
        assert_enqueued_jobs 2 do
          deliverable.reanalyze_submissions
        end
      end

      it 'reanalyzes all submissions' do
        skip 'requires docker'
        deliverable.submissions.each do |s|
          assert_equal :queued, s.analysis.status
        end
        perform_enqueued_jobs do
          deliverable.reanalyze_submissions
        end

        statuses = deliverable.submissions.reload.map { |s| s.analysis.status }
        assert_equal [:ok, :wrong].to_set, statuses.to_set
      end
    end

    describe 'deliverable analyzer is a DockerAnalyzer' do
      let(:code_deliverable) { deliverables(:assessment_code) }

      it 'queues all submissions for reanalysis' do
        assert_enqueued_jobs 2 do
          code_deliverable.reanalyze_submissions
        end
      end

      it 'reanalyzes all submissions' do
        skip 'requires docker'
        code_deliverable.submissions.each do |s|
          assert_equal true, s.analysis.nil? || (s.analysis.status != :ok)
        end
        perform_enqueued_jobs do
          code_deliverable.reanalyze_submissions
        end

        code_deliverable.submissions.reload.each do |s|
          assert_equal :ok, s.analysis.status
        end
      end
    end
  end
end
