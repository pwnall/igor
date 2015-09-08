require 'test_helper'

class DeliverableTest < ActiveSupport::TestCase
  before do
    @deliverable = Deliverable.new assignment: assignments(:ps1),
        file_ext: 'pdf', name: 'Extra Credit', description: 'Bonus for PS1'
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

  it 'validates an associated analyzer' do
    analyzer = @deliverable.build_analyzer
    assert_equal false, analyzer.valid?
    assert_equal false, @deliverable.valid?
  end

  it 'saves the associated ProcAnalyzer through the parent deliverable' do
    assert_nil @deliverable.analyzer
    deliverable_params = { analyzer_attributes: {
      type: 'ProcAnalyzer', auto_grading: 0, message_name: 'analyze_pdf'
    } }
    @deliverable.update! deliverable_params

    assert_instance_of ProcAnalyzer, @deliverable.reload.analyzer
  end

  it 'saves the associated ScriptAnalyzer through the parent deliverable' do
    assert_nil @deliverable.analyzer
    attachment = fixture_file_upload 'analyzer_files/fib.zip',
        'application/zip', :binary
    deliverable_params = { analyzer_attributes: {
      type: 'ScriptAnalyzer', auto_grading: 1, time_limit: 2, ram_limit: 1024,
      file_limit: 10, file_size_limit: 100, process_limit: 5,
      db_file_attributes: { f: attachment }
    } }
    @deliverable.update! deliverable_params

    assert_instance_of ScriptAnalyzer, @deliverable.reload.analyzer
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
    let(:submission_count) { deliverable.submissions.count }

    before do
      assert_operator 2, :<=, submission_count
    end

    describe 'deliverable has analyzer' do
      before { assert_not_nil deliverable.analyzer }

      it 'queues all submissions for reanalysis' do
        assert_difference 'Delayed::Job.count', submission_count do
          deliverable.reanalyze_submissions
        end
      end

      it 'reanalyzes all submissions' do
        deliverable.reanalyze_submissions

        assert_equal [submission_count, 0], Delayed::Worker.new.work_off
        statuses = deliverable.reload.submissions.map { |s| s.analysis.status }
        assert_equal [:ok, :wrong], statuses.sort!
      end
    end

    describe 'deliverable has no analyzer' do
      before { deliverable.analyzer.destroy }

      it 'sets analysis status to :no_analyzer for all submissions' do
        assert_no_difference 'Delayed::Job.count' do
          deliverable.reanalyze_submissions
        end
        statuses = deliverable.submissions.reload.map { |s| s.analysis.status }
        assert_equal true, statuses.all? { |status| status == :no_analyzer }
      end
    end
  end
end
