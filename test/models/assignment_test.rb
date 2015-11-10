require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  before do
    @due_at = 1.week.from_now.round 0  # Remove sub-second information.
    @assignment = Assignment.new course: courses(:main), name: 'Final Exam',
        author: users(:main_staff), due_at: @due_at, weight: 50,
        published_at: 1.week.ago, grades_published: false
  end

  let(:assignment) { assignments(:assessment) }
  let(:unreleased_exam) { assignments(:main_exam) }
  let(:gradeless_assignment) { assignments(:ps3) }
  let(:student) { users(:dexter) }
  let(:any_user) { User.new }
  let(:admin) { users(:admin) }
  let(:extension) { assignment.extensions.find_by user: student }

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
        assert_equal true, assignment.published?
        assert_equal true, assignment.can_read?(any_user)
        assert_equal true, assignment.can_read?(nil)
      end

      it 'lets any user view assignment if grades have been released' do
        assignment.update! grades_published: true
        assert_equal true, assignment.can_read?(any_user)
        assert_equal true, assignment.can_read?(nil)
      end

      it 'lets only admin view assignments under construction' do
        assignment.update! published_at: 1.day.from_now, grades_published: false
        assert_equal true, assignment.can_read?(admin)
        assert_equal false, assignment.can_read?(any_user)
        assert_equal false, assignment.can_read?(nil)
      end
    end

    describe '#can_student_submit?' do
      describe 'assignment is published' do
        before { assert_equal true, assignment.published? }

        describe 'neither original deadline nor extension, if any, passed' do
          before do
            assignment.update! due_at: 1.day.from_now
            extension.update! due_at: 1.week.from_now
          end

          it 'returns true for any user' do
            assert_equal true,
                assignment.can_student_submit?(any_user)
            assert_equal true, assignment.can_student_submit?(student)
            assert_equal true, assignment.can_student_submit?(admin)
            assert_equal true, assignment.can_student_submit?(nil)
          end
        end

        describe 'original deadline passed but user has active extension' do
          before do
            assignment.update! due_at: 1.week.ago
            extension.update! due_at: 1.day.from_now
          end

          it 'returns true for the student with an extension' do
            assert_equal true, assignment.can_student_submit?(student)
          end

          it 'returns false for all users without an extension' do
            assert_nil users(:solo).extensions.find_by subject: assignment
            assert_equal false,
                assignment.can_student_submit?(users(:solo))
            assert_equal false,
                assignment.can_student_submit?(users(:main_staff))
            assert_equal false, assignment.can_student_submit?(admin)
            assert_equal false, assignment.can_student_submit?(nil)
          end
        end

        describe 'both original deadline and extension, if any, have passed' do
          before do
            assignment.update! due_at: 2.days.ago
            extension.update! due_at: 1.day.ago
          end

          it 'returns false for all users' do
            assert_equal false,
                assignment.can_student_submit?(student)
            assert_equal false, assignment.can_student_submit?(nil)
            assert_equal false,
                assignment.can_student_submit?(users(:main_staff))
            assert_equal false, assignment.can_student_submit?(admin)
          end
        end
      end

      describe 'assignment has not been published' do
        before { assignment.update! published_at: 1.day.from_now }

        describe 'neither original deadline nor extension, if any, passed' do
          before do
            assert_equal false, assignment.deadline_passed_for?(student)
          end

          it 'returns false for all users' do
            assert_equal false,
                assignment.can_student_submit?(student)
            assert_equal false, assignment.can_student_submit?(nil)
            assert_equal false,
                assignment.can_student_submit?(users(:main_staff))
            assert_equal false, assignment.can_student_submit?(admin)
          end
        end
      end
    end

    describe '#can_submit?' do
      describe 'assignment is published' do
        before { assert_equal true, assignment.published? }

        describe 'neither original deadline nor extension, if any, passed' do
          before do
            assignment.update! due_at: 1.day.from_now
            extension.update! due_at: 1.week.from_now
          end

          it 'lets any user submit' do
            assert_equal true, assignment.can_submit?(any_user)
            assert_equal true, assignment.can_submit?(student)
            assert_equal true, assignment.can_submit?(admin)
            assert_equal true, assignment.can_submit?(nil)
          end
        end

        describe 'original deadline passed but user has active extension' do
          before do
            assignment.update! due_at: 1.week.ago
            extension.update! due_at: 1.day.from_now
          end

          it 'lets the student submit' do
            assert_equal true, assignment.can_submit?(student)
          end

          it 'forbids other students without an extension from submitting' do
            assert_nil users(:solo).extensions.find_by subject: assignment
            assert_equal false, assignment.can_submit?(users(:solo))
            assert_equal false, assignment.can_submit?(nil)
          end

          it 'lets course/site admins submit' do
            assert_equal true, assignment.can_submit?(users(:main_staff))
            assert_equal true, assignment.can_submit?(admin)
          end
        end

        describe 'both original deadline and extension, if any, have passed' do
          before do
            assignment.update! due_at: 2.days.ago
            extension.update! due_at: 1.day.ago
          end

          it 'lets only course/site admins submit' do
            assert_equal false, assignment.can_submit?(student)
            assert_equal false, assignment.can_submit?(nil)
            assert_equal true, assignment.can_submit?(users(:main_staff))
            assert_equal true, assignment.can_submit?(admin)
          end
        end
      end

      describe 'assignment has not been published' do
        before { assignment.update! published_at: 1.day.from_now }

        describe 'neither original deadline nor extension, if any, passed' do
          before do
            assert_equal false, assignment.deadline_passed_for?(student)
          end

          it 'lets only course/site admins submit' do
            assert_equal false, assignment.can_submit?(student)
            assert_equal false, assignment.can_submit?(nil)
            assert_equal true, assignment.can_submit?(users(:main_staff))
            assert_equal true, assignment.can_submit?(admin)
          end
        end
      end
    end
  end

  describe 'homework submission feature' do
    describe 'HasDeadline concern' do
      it 'requires a deadline' do
        @assignment.deadline = nil
        assert @assignment.invalid?
      end

      it 'destroys dependent records' do
        assert_not_nil assignment.deadline

        assignment.destroy

        assert_nil Deadline.find_by(subject: assignment)
      end

      it 'saves the associated deadline through the parent assignment' do
        new_time = @due_at + 1.day
        params = { deadline_attributes: { due_at: new_time } }
        @assignment.update! params

        assert_equal new_time, @assignment.reload.due_at
      end

      describe 'by_deadline scope' do
        it 'sorts assignments by ascending deadline, then by name' do
          golden = assignments(:project, :main_exam_2, :assessment, :ps3,
                               :main_exam, :ps2, :ps1)
          actual = courses(:main).assignments.by_deadline
          assert_equal golden, actual, actual.map(&:name)
        end
      end

      describe 'with_upcoming_deadline scope' do
        it 'returns assignments whose deadlines have not passed' do
          golden = assignments(:ps3, :project, :assessment, :main_exam,
                               :main_exam_2)
          actual = courses(:main).assignments.with_upcoming_deadline
          assert_equal golden.to_set, actual.to_set, actual.map(&:name)
        end
      end

      describe '.with_upcoming_extension_for' do
        it 'returns assignments for which the user has an upcoming extension' do
          golden = assignments(:ps2, :assessment)
          actual = courses(:main).assignments.
              with_upcoming_extension_for users(:dexter)
          assert_equal golden.to_set, actual.to_set, actual.map(&:name)
        end
      end

      describe '.upcoming_for' do
        it 'returns published assignments the student can complete' do
          golden = assignments(:ps2, :ps3, :assessment)
          actual = courses(:main).assignments.upcoming_for users(:dexter)
          assert_equal golden.to_set, actual.to_set, actual.map(&:name)
        end
      end

      describe 'past_due scope' do
        it 'returns assignments whose deadlines have passed' do
          golden = assignments(:ps1, :ps2)
          actual = courses(:main).assignments.past_due
          assert_equal golden.to_set, actual.to_set, actual.map(&:name)
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

      describe 'student does not have an extension' do
        it 'has correct test conditions' do
          assert_nil @assignment.extensions.find_by user: student
        end

        describe '#due_at_for' do
          it 'returns the original due date' do
            assert_equal @assignment.due_at, @assignment.due_at_for(student)
            assert_equal @assignment.due_at, @assignment.due_at_for(nil), 10
          end
        end

        describe '#deadline_passed_for?' do
          it 'returns whether the deadline has passed' do
            @assignment.deadline.update! due_at: 1.day.from_now
            assert_equal false, @assignment.deadline_passed_for?(any_user)
            assert_equal false, @assignment.deadline_passed_for?(nil)

            @assignment.deadline.update! due_at: 1.day.ago
            assert_equal true, @assignment.deadline_passed_for?(any_user)
            assert_equal true, @assignment.deadline_passed_for?(nil)
          end
        end
      end

      describe 'student has an extension' do
        describe '#due_at_for' do
          it 'returns the extended due date' do
            assert_equal extension.due_at, assignment.due_at_for(student)
          end

          it 'returns the original due date if subject is nil' do
            assert_equal assignment.due_at, assignment.due_at_for(nil)
          end
        end

        describe '#deadline_passed_for?' do
          describe 'only the original deadline has passed' do
            before do
              assignment.update! due_at: 2.days.ago
              extension.update! due_at: 1.day.from_now
            end

            it 'returns false' do
              assert_equal false, assignment.deadline_passed_for?(student)
            end

            it 'returns true if the subject is nil' do
              assert_equal true, assignment.deadline_passed_for?(nil)
            end
          end

          describe 'both the original and extended deadlines have passed' do
            before do
              assignment.update! due_at: 2.days.ago
              extension.update! due_at: 1.day.ago
            end

            it 'returns true' do
              assert_equal true, assignment.deadline_passed_for?(student)
            end

            it 'returns true if the subject is nil' do
              assert_equal true, assignment.deadline_passed_for?(nil)
            end
          end

          describe 'neither the original nor the extended deadline passed' do
            before do
              assignment.update! due_at: 1.week.from_now
              extension.update! due_at: 2.weeks.from_now
            end

            it 'returns false' do
              assert_equal false, assignment.deadline_passed_for?(student)
            end

            it 'returns false if the subject is nil' do
              assert_equal false, assignment.deadline_passed_for?(nil)
            end
          end
        end
      end
    end

    it 'destroys dependent records' do
      assert_not_empty assignment.deliverables
      assert_not_empty assignment.extensions

      assignment.destroy

      assert_empty assignment.deliverables.reload
      assert_empty assignment.extensions.reload
    end

    it 'validates associated deliverables' do
      deliverable = @assignment.deliverables.build
      assert_equal false, deliverable.valid?
      assert_equal false, @assignment.valid?
    end

    it 'saves associated deliverables through the parent assignment' do
      params = { assignment: { deliverables_attributes: [
        { name: 'PS Write-Up', description: 'Report', file_ext: 'pdf',
        analyzer_attributes: { type: 'ProcAnalyzer',
        message_name: 'analyze_pdf', auto_grading: 0 } }
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

      describe 'assignment is published' do
        it 'returns all deliverables' do
          assert_equal true, assignment.published?
          actual = assignment.deliverables_for(any_user).sort_by(&:name)
          assert_equal golden, actual, actual.map(&:name)
        end
      end

      describe 'assignment has not been published' do
        before { assignment.update! published_at: 1.day.from_now }

        it 'returns an empty collection for non-admin users' do
          assert_empty assignment.deliverables_for(any_user)
          assert_empty assignment.deliverables_for(nil)
        end

        it 'returns all deliverables for course/site admins' do
          actual = assignment.deliverables_for(admin).sort_by(&:name)
          assert_equal golden, actual, actual.map(&:name)
        end
      end
    end

    describe '#expected_submissions' do
      it 'returns the number of deliverables x number of enrolled students' do
        assert_equal 2, assignment.deliverables.count
        assert_equal 4, assignment.course.students.count
        assert_equal 8, assignment.expected_submissions
      end
    end
  end

  describe 'grade collection and publishing feature' do
    it 'rejects negative weights' do
      @assignment.weight = -5
      assert @assignment.invalid?
    end

    describe 'grades have not been published yet' do
      before { assert_equal false, @assignment.grades_published }

      it 'does not require a release date' do
        @assignment.published_at = nil
        assert @assignment.valid?
      end

      it 'requires the release date to occur before the base deadline' do
        @assignment.published_at = @assignment.due_at + 1.day
        assert @assignment.invalid?
      end
    end

    describe 'grades have been released' do
      before { @assignment.grades_published = true }

      it 'requires a release date' do
        @assignment.published_at = nil
        assert @assignment.invalid?
      end

      it 'requires the release date to occur before the base deadline' do
        @assignment.published_at = @assignment.due_at + 1.day
        assert @assignment.invalid?
      end

      it 'requires the release date to have passed' do
        @assignment.published_at = 1.day.from_now
        @assignment.grades_published = true
        assert @assignment.invalid?
      end
    end

    describe '#act_on_reset_published_at' do
      describe 'publish date has not been set yet' do
        before { assignment.update! published_at: nil }

        it 'updates the publish date if :reset_publish_date is false' do
          published_at = 1.day.from_now
          assignment.update! published_at: published_at,
                             reset_publish_date: '0'
          assert_equal published_at, assignment.published_at
        end

        it 'overrides :published_at update if :reset_publish_date is true' do
          assignment.update! published_at: 1.day.from_now,
                             reset_publish_date: '1'
          assert_nil assignment.published_at
        end
      end

      describe 'publish date has been set' do
        before { assert_not_nil assignment.published_at }

        it 'nullifies the publish date if :reset_publish_date is true' do
          assignment.update! reset_publish_date: '1'
          assert_nil assignment.published_at
        end

        it 'overrides :published_at update if :reset_publish_date is true' do
          assignment.update! published_at: 1.year.ago, reset_publish_date: '1'
          assert_nil assignment.published_at
        end

        it 'does not change :published_at if :reset_publish_date is false' do
          published_at = assignment.published_at
          assignment.update! reset_publish_date: '0'
          assert_equal published_at, assignment.published_at
        end
      end
    end

    it 'must state whether or not students can view their grades' do
      @assignment.grades_published = nil
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
      params = { metrics_attributes: [{ name: 'Other', max_score: 20,
                                        weight: 0 }] }

      assert_difference '@assignment.metrics.count' do
        @assignment.update! params
      end
    end

    it "doesn't save associated metrics with blank nested attributes" do
      params = { metrics_attributes: [{ name: '', max_score: '', weight: '' }] }

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

    describe '#reset_publish_date' do
      it 'returns true if the author has not chosen a release date' do
        assignment.update! published_at: nil
        assert_equal true, assignment.reload.reset_publish_date
      end

      it 'returns false if the author has chosen a release date' do
        assert_not_nil assignment.published_at
        assert_equal false, assignment.reload.reset_publish_date
      end
    end

    describe '#reset_publish_date=' do
      it "sets :reset_publish_date to true if the argument is '1'" do
        assert_equal false, assignment.reset_publish_date
        assignment.update! reset_publish_date: '1'
        assert_equal true, assignment.reload.reset_publish_date
      end

      it "sets :reset_publish_date to false if the argument is '0' and a
          new publish date is provided" do
        assignment.update! published_at: nil
        assert_equal true, assignment.reset_publish_date
        assignment.update! published_at: 1.day.from_now,
                           reset_publish_date: '0'
        assert_equal false, assignment.reload.reset_publish_date
      end
    end

    describe '#published?' do
      it 'returns true if the deliverables have been released' do
        assert_operator assignment.published_at, :<, Time.current
        assert_equal true, assignment.published?
      end

      it 'returns false if the deliverables have not been released' do
        @assignment.published_at = 1.day.from_now
        assert_equal false, @assignment.published?
      end
    end

    describe '#expected_grades' do
      it 'returns the number of metrics x number of enrolled students' do
        assert_equal 2, assignment.metrics.count
        assert_equal 4, assignment.course.students.count
        assert_equal 8, assignment.expected_grades
      end
    end
  end

  describe 'score calculations' do
    describe '#max_score' do
      describe 'assignment has no metrics' do
        before { assert_empty unreleased_exam.metrics }

        it 'returns nil' do
          assert_nil unreleased_exam.max_score
        end
      end

      describe 'assignment has metrics' do
        it 'returns the weighted maximum score' do
          assert_equal 100, assignment.max_score
        end
      end
    end

    describe '#average_score' do
      let(:unreleased_assignment) { assignments(:ps3) }
      let(:unreleased_exam) { assignments(:main_exam) }

      describe 'assignment has no metrics' do
        before { assert_empty unreleased_exam.metrics }

        it 'returns nil' do
          assert_nil unreleased_exam.average_score
        end
      end

      describe 'no grades have been issued yet' do
        before { assert_empty gradeless_assignment.grades }

        it 'returns 0' do
          assert_equal 0, gradeless_assignment.average_score
        end
      end

      describe 'grades have been issued' do
        before { assert_not_empty assignment.grades }

        it 'returns the average weighted score on the assignment' do
          # (70*1 + (10*1 + 10*0) + 6*0) / 3.0 = 30
          assert_equal 30, assignment.average_score
        end
      end
    end

    describe '#recitation_score' do
      let(:section) { recitation_sections(:r01) }

      it 'returns the average recitation score on individual assignments' do
        students = section.users
        assert_equal 2, assignment.metrics.count
        overall_metric, quality_metric = assignment.metrics.sort_by(&:name)

        assert_equal [10.0, 80.0],
            overall_metric.grades.where(subject: students).map(&:score).sort
        assert_equal [10.0],
            quality_metric.grades.where(subject: students).map(&:score).sort
        # ((10 + 80) / 2)*1 + (10 / 1)*0 = 45
        assert_equal 45, assignment.recitation_score(section)
      end

      # TODO(spark008): Write test for team assignments.
      it 'returns the average recitation score on team assignments' do
      end
    end

    describe 'AverageScore concern' do
      describe '#average_score_percentage' do
        describe 'assignment has no metrics' do
          before { assert_empty unreleased_exam.metrics }

          it 'returns nil' do
            assert_nil unreleased_exam.average_score_percentage
          end
        end

        describe 'max score is 0' do
          before { assignment.metrics.update_all max_score: 0 }

          it 'returns 0' do
            assert_equal 0, assignment.reload.average_score_percentage
          end
        end

        describe 'assignment has metrics with non-zero max scores' do
          it 'returns the average score as a percentage' do
            # (((80 + 10 + 0) / 100)*1 + ((0 + 10 + 6) / 10)*0) / 3 = 30
            assert_equal 30, assignment.average_score_percentage
          end
        end
      end
    end
  end

  describe 'lifecycle' do
    describe '#ui_state_for' do
      describe 'deliverables not published' do
        before do
          assignment.update! published_at: 1.week.from_now,
              due_at: 2.weeks.from_now, grades_published: false
        end

        it 'returns :draft' do
          assert_equal :draft, assignment.reload.ui_state_for(student)
        end
      end

      describe 'deliverables have been published' do
        before { assert_operator assignment.published_at, :<, Time.current }

        describe 'grades not ready yet' do
          before { assert_equal false, assignment.grades_published? }

          describe 'deadline has not passed yet for the user' do
            before do
              assert_equal false, assignment.deadline_passed_for?(student)
            end

            it 'returns :open' do
              assert_equal :open, assignment.ui_state_for(student)
            end
          end

          describe 'deadline has passed for the user' do
            before do
              assignment.update! due_at: 2.days.ago
              extension.update! due_at: 1.day.ago
            end

            it 'returns :grading' do
              assert_equal :grading, assignment.reload.ui_state_for(student)
            end
          end
        end

        describe 'grades have been released' do
          before do
            assignment.update! due_at: 1.day.ago, grades_published: true
          end

          it 'returns :graded' do
            assert_equal :graded, assignment.reload.ui_state_for(student)
          end
        end
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
