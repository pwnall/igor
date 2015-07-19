require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  before do
    @due_at = 1.week.from_now
    @assignment = Assignment.new course: courses(:main), name: 'Final Exam',
        author: users(:main_staff), due_at: @due_at, weight: 50,
        deliverables_ready: true, metrics_ready: false
  end

  let(:assignment) { assignments(:assessment) }
  let(:any_user) { User.new }

  it 'validates the setup assignment' do
    assert @assignment.valid?, @assignment.errors.full_messages
  end

  describe 'core functionality' do
    it 'requires a course' do
      @assignment.course = nil
      assert @assignment.invalid?
    end

    it 'requires a name' do
      @assignment.name = nil
      assert @assignment.invalid?
    end

    it 'rejects lengthy names' do
      @assignment.name = 'a' * 65
      assert @assignment.invalid?
    end

    it 'forbids assignments in the same course from having the same name' do
      @assignment.name = @assignment.course.assignments.first.name
      assert @assignment.invalid?
    end

    it 'requires an author' do
      @assignment.author = nil
      assert @assignment.invalid?
    end

    describe '#can_read?' do
      it 'lets any user view assignment if deliverables have been released' do
        assignment.update! deliverables_ready: true
        assert_equal true, assignment.can_read?(any_user)
        assert_equal true, assignment.can_read?(nil)
      end

      it 'lets any user view assignment if grades have been released' do
        assignment.update! metrics_ready: true
        assert_equal true, assignment.can_read?(any_user)
        assert_equal true, assignment.can_read?(nil)
      end

      it 'lets only admin view assignments under construction' do
        assignment.update! deliverables_ready: false, metrics_ready: false
        assert_equal false, assignment.can_read?(any_user)
        assert_equal false, assignment.can_read?(nil)
      end
    end
  end

  describe 'homework submission feature' do
    it 'requires a deadline' do
      @assignment.deadline = nil
      assert @assignment.invalid?
    end

    it 'saves the associated deadline through the parent assignment' do
      new_time = @due_at + 1.day
      params = { deadline_attributes: { due_at: new_time } }
      @assignment.update! params

      assert_equal new_time, @assignment.due_at
    end

    describe 'by_deadline scope' do
      it 'sorts assignments by ascending deadline, then by name' do
        golden = assignments(:project, :not_main_exam, :ps2, :assessment, :ps1)
        actual = Assignment.by_deadline
        assert_equal golden, actual, actual.map(&:name)
      end
    end

    describe '#due_at' do
      it 'returns the date when the assignment is due' do
        assert_equal @due_at, @assignment.due_at
      end

      it 'returns nil if the deadline has not been set' do
        @assignment.deadline = nil
        assert_nil @assignment.due_at
      end
    end

    describe '#due_at=' do
      it 'builds a deadline with the given date if one does not exist' do
        @assignment.deadline = nil
        new_time = @due_at + 1.day
        @assignment.due_at = new_time

        assert_equal new_time, @assignment.deadline.due_at
        assert_equal courses(:main), @assignment.deadline.course
      end

      it 'updates the due date of an existing deadline' do
        assert @assignment.deadline
        new_time = @due_at + 1.day
        @assignment.due_at = new_time

        assert_equal new_time, @assignment.deadline.due_at
      end
    end

    # TODO(spark008): Retest this method when extensions have been implemented.
    describe '#deadline_for' do
      it 'returns the deadline for the given user' do
        assert_equal @due_at, @assignment.deadline_for(any_user)
      end
    end

    # TODO(spark008): Retest this method when extensions have been implemented.
    describe '#deadline_passed_for?' do
      it 'return whether the deadline has passed' do
        assignment.deadline.update! due_at: 1.day.from_now
        assert_equal false, assignment.deadline_passed_for?(any_user)

        assignment.deadline.update! due_at: 1.day.ago
        assert_equal true, assignment.deadline_passed_for?(any_user)
      end
    end

    describe '.for' do
      it 'returns all assignments for the course if the user is an admin' do
        golden = assignments(:project, :ps2, :assessment, :ps1)
        actual = Assignment.for users(:admin), courses(:main)
        assert_equal golden, actual, actual.map(&:name)
      end

      it 'returns assignments with released deliverables/grades if non-admin' do
        golden = assignments(:project, :assessment, :ps1)
        actual = Assignment.for any_user, courses(:main)
        assert_equal golden, actual, actual.map(&:name)
      end
    end

    it 'must state whether or not students can access deliverables' do
      @assignment.deliverables_ready = nil
      assert_equal false, @assignment.valid?
    end

    it 'destroys dependent records' do
      assert_equal true, assignment.deliverables.any?

      assignment.destroy

      assert_empty assignment.deliverables.reload
    end

    it 'validates associated deliverables' do
      deliverable = @assignment.deliverables.build
      assert_equal false, deliverable.valid?
      assert_equal false, @assignment.valid?
    end

    it 'saves associated deliverables through the parent assignment' do
      params = { assignment: { deliverables_attributes: [
        { name: 'PS Write-Up', description: 'Report', file_ext: 'pdf' },
        { name: '', description: '', file_ext: '' }
      ] } }
      @assignment.update! params[:assignment]

      assert_equal 1, @assignment.deliverables.count
    end

    it 'destroys associated deliverables through the parent assignment' do
      params = { assignment: { deliverables_attributes: [
        { id: assignment.deliverables.first.id, _destroy: true }
      ] } }

      assert_difference 'assignment.deliverables.count', -1 do
        assignment.update! params[:assignment]
      end
    end

    describe '#deliverables_for' do
      let(:golden) { deliverables(:assessment_writeup, :assessment_code) }

      it 'returns all deliverables if :deliverables_ready is true' do
        assignment.update! deliverables_ready: true
        actual = assignment.deliverables_for(any_user).sort_by(&:name)
        assert_equal golden, actual, actual.map(&:name)
      end

      it 'returns all deliverables, even if not ready, for admins' do
        assignment.update! deliverables_ready: false
        actual = assignment.deliverables_for(users(:admin)).sort_by(&:name)
        assert_equal golden, actual, actual.map(&:name)
      end

      it "returns an empty array for non-admins if deliverables aren't ready" do
        assignment.update! deliverables_ready: false
        assignment.deliverables_ready = false
        assert_equal [], assignment.deliverables_for(any_user)
      end
    end

    describe '#expected_submissions' do
      it 'returns the number of deliverables x number of enrolled students' do
        assert_equal 2, assignment.deliverables.count
        assert_equal 3, assignment.course.students.count
        assert_equal 6, assignment.expected_submissions
      end
    end
  end

  describe 'grade collection and publishing feature' do
    it 'rejects negative weights' do
      @assignment.weight = -5
      assert @assignment.invalid?
    end

    it 'rejects weights greater than 100' do
      @assignment.weight = 200
      assert @assignment.invalid?
    end

    it 'must state whether or not students can view their grades' do
      @assignment.metrics_ready = nil
      assert @assignment.invalid?
    end

    it 'destroys dependent records' do
      assert_equal true, assignment.metrics.any?

      assignment.destroy

      assert_empty assignment.metrics.reload
    end

    it 'validates associated metrics' do
      metric = @assignment.metrics.build
      assert metric.invalid?
      assert @assignment.invalid?
    end

    it 'saves associated metrics through the parent assignment' do
      params = { metrics_attributes: [{ name: 'Other', max_score: 20 }] }

      assert_difference '@assignment.metrics.count' do
        @assignment.update! params
      end
    end

    it "doesn't save associated metrics with blank nested attributes" do
      params = { metrics_attributes: [{ name: '', max_score: '' }] }

      assert_no_difference 'assignment.metrics.count' do
        @assignment.update! params
      end
    end

    it 'destroys associated metrics through the parent assignment' do
      metric = assignment.metrics.first
      params = { metrics_attributes: [{ id: metric.id, _destroy: true }] }

      assert_difference 'assignment.metrics.count', -1 do
        assignment.update! params
      end
    end

    describe '#expected_grades' do
      it 'returns the number of metrics x number of enrolled students' do
        assert_equal 2, assignment.metrics.count
        assert_equal 3, assignment.course.students.count
        assert_equal 6, assignment.expected_grades
      end
    end

    describe '#max_score' do
      it 'returns the maximum possible score achievable on this assignment' do
        assert_equal [10, 100], assignment.metrics.map(&:max_score).sort
        assert_equal 110, assignment.max_score
      end
    end

    describe '#recitation_score' do
      let(:section) { recitation_sections(:r01) }

      it 'returns the average recitation score on individual assignments' do
        students = section.users
        assert_equal 2, assignment.metrics.count
        overall_metric, quality_metric = assignment.metrics.sort_by(&:name)

        assert_equal [10.0, 70.0],
            overall_metric.grades.where(subject: students).map(&:score).sort
        assert_equal [10.0],
            quality_metric.grades.where(subject: students).map(&:score).sort
        assert_equal 50.0, assignment.recitation_score(section)
      end

      # TODO(spark008): Write test for team assignments.
      it 'returns the average recitation score on team assignments' do
      end
    end
  end

  describe 'lifecycle' do
    describe '#ui_state_for' do
      it 'returns :draft for assignments under construction' do
        @assignment.deliverables_ready = false
        assert_equal :draft, @assignment.ui_state_for(any_user)
      end

      it 'returns :open if accepting submissions and deliverables exist' do
        @assignment.deliverables.build
        assert_equal true, @assignment.deliverables.any?
        assert_equal :open, @assignment.ui_state_for(any_user)
      end

      it 'returns :grading if :open, but the deliverables are missing' do
        assert_empty @assignment.deliverables
        assert_equal :grading, @assignment.ui_state_for(any_user)
      end

      it 'returns :grading if the deadline passed and grades are not ready' do
        @assignment.due_at = 1.week.ago
        assert_equal :grading, @assignment.ui_state_for(any_user)
      end

      it 'returns :graded if grades have been released' do
        @assignment.metrics_ready = true
        assert_equal :graded, @assignment.ui_state_for(any_user)
      end
    end
  end

  describe 'team integration' do
    describe '#grade_subject_for' do
      it 'returns the input if the assignment has no team partition' do
        assert_nil @assignment.team_partition
        assert_equal any_user, @assignment.grade_subject_for(any_user)
      end

      it "returns the user's team if the assignment has a team partition" do
        @assignment.team_partition = team_partitions(:psets)
        assert_equal teams(:awesome_pset),
            @assignment.grade_subject_for(users(:dexter))
      end
    end
  end
end
