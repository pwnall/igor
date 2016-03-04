require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  before do
    @due_at = 1.week.from_now.round 0  # Remove sub-second information.
    @assignment = Assignment.new course: courses(:main), name: 'Final Exam',
        author: users(:main_staff), due_at: @due_at, weight: 50,
        scheduled: true, released_at: 1.week.ago, grades_released: false
  end

  let(:assignment) { assignments(:assessment) }
  let(:unreleased_exam) { assignments(:main_exam) }
  let(:undecided_exam) { assignments(:main_exam_2) }
  let(:gradeless_assignment) { assignments(:ps3) }
  let(:student) { users(:dexter) }
  let(:any_user) { User.new }
  let(:admin) { users(:admin) }
  let(:extension) { assignment.extensions.find_by user: student }
  let(:current_hour) { Time.current.beginning_of_hour }

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

    describe '#author_exuid' do
      it 'returns the exuid of the author' do
        assert_equal users(:main_staff).to_param, @assignment.author_exuid
      end

      it 'returns nil if the user has not been set' do
        @assignment.author = nil
        assert_nil @assignment.author_exuid
      end
    end

    describe '#author_exuid=' do
      it 'sets the author to the user with the given exuid' do
        @assignment.author_exuid = users(:main_staff_2).to_param
        assert_equal users(:main_staff_2), @assignment.author
      end

      it 'sets the author to nil if no user with the given exuid exists' do
        nonexistent_exuid = users(:main_staff_2).to_param
        users(:main_staff_2).destroy
        @assignment.author_exuid = nonexistent_exuid
        assert_nil @assignment.author
      end
    end

    it 'requires a scheduled flag' do
      @assignment.scheduled = nil
      assert @assignment.invalid?
    end

    it 'accepts having scheduled set to false' do
      @assignment.scheduled = false
      assert @assignment.valid?, @assignment.errors.full_messages
    end

    describe '#can_read_schedule?' do
      it 'lets any user see assignment if deliverables have been released' do
        assert_equal true, assignment.released?
        assert_equal true, assignment.can_read_schedule?(any_user)
        assert_equal true, assignment.can_read_schedule?(nil)
      end

      it 'lets any user see assignment if grades have been released' do
        assignment.update! grades_released: true
        assert_equal true, assignment.can_read_schedule?(any_user)
        assert_equal true, assignment.can_read_schedule?(nil)
      end

      it 'lets any user see locked assignments' do
        assignment.update! released_at: 1.day.from_now, grades_released: false
        assert_equal true, assignment.can_read_schedule?(any_user)
        assert_equal true, assignment.can_read_schedule?(nil)
      end

      it 'only lets course staff see un-scheduled assignments' do
        assert_equal true, assignment.released?
        assignment.update! scheduled: false, grades_released: false
        assert_equal true, assignment.can_read_schedule?(admin)
        assert_equal true, assignment.can_read_schedule?(users(:main_staff))
        assert_equal false, assignment.can_read_schedule?(any_user)
        assert_equal false, assignment.can_read_schedule?(nil)
      end
    end

    describe '#can_read_content?' do
      describe 'assignment is a standard homework' do
        before { assert_nil assignment.exam }

        it 'lets any user read scheduled assignments whose deliverables have
            been released' do
          assignment.update! scheduled: true, released_at: 1.day.ago
          assert_equal true, assignment.can_read_content?(any_user)
          assert_equal true, assignment.can_read_content?(nil)
        end

        it 'lets only course staff read unscheduled assignments whose
            deliverables have been released' do
          assignment.update! scheduled: false, released_at: 1.day.ago
          assert_equal true, assignment.can_read_content?(admin)
          assert_equal true, assignment.can_read_content?(users(:main_staff))
          assert_equal false, assignment.can_read_content?(any_user)
          assert_equal false, assignment.can_read_content?(nil)
        end

        it 'lets only course staff read scheduled assignments whose deliverables
            have not been released' do
          assignment.update! scheduled: false, released_at: 1.day.from_now,
          grades_released: false
          assert_equal true, assignment.can_read_content?(admin)
          assert_equal true, assignment.can_read_content?(users(:main_staff))
          assert_equal false, assignment.can_read_content?(any_user)
          assert_equal false, assignment.can_read_content?(nil)
        end

        it 'lets only course staff read unscheduled assignments whose
            deliverables have not been released' do
          assignment.update! scheduled: true, released_at: 1.day.from_now,
              grades_released: false
          assert_equal true, assignment.can_read_content?(admin)
          assert_equal true, assignment.can_read_content?(users(:main_staff))
          assert_equal false, assignment.can_read_content?(any_user)
          assert_equal false, assignment.can_read_content?(nil)
        end
      end

      describe 'assignment is an exam' do
        before do
          @exam = unreleased_exam
          @exam_attendance = @exam.exam.attendances.find_by user: student
          @exam_session = @exam_attendance.exam_session
          assert @exam.exam
        end

        describe 'deliverables released, due date scheduled' do
          before { @exam.update! scheduled: true, released_at: 1.day.ago }

          it 'lets course staff view assignment resources' do
            assert_equal true, @exam.can_read_content?(admin)
            assert_equal true, @exam.can_read_content?(users(:main_staff))
          end

          it 'lets students view assignment resources if their exam session has
              started' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal true, @exam.can_read_content?(student)
          end

          it 'forbids students from viewing assignment resources if their exam
              session has not started yet' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students from viewing assignment resources if their exam
              attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids non-signed-up students from viewing assignment
              resources' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.can_read_content?(users(:deedee))
          end
        end

        describe 'deliverables released, due date unscheduled' do
          before { @exam.update! scheduled: false, released_at: 1.day.ago }

          it 'lets only course staff view assignment resources' do
            assert_equal true, @exam.can_read_content?(admin)
            assert_equal true, @exam.can_read_content?(users(:main_staff))
          end

          it 'forbids students whose exam session started from viewing
              assignment resources' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students whose exam session has not started from viewing
              assignment resources' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students from viewing assignment resources if their exam
              attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids non-checked-in students from viewing assignment
              resources' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.can_read_content?(users(:deedee))
          end
        end

        describe 'deliverables not released, due date scheduled' do
          before do
            @exam.update! scheduled: true, released_at: 1.day.from_now,
                grades_released: false
          end

          it 'lets only course staff view assignment resources' do
            assert_equal true, @exam.can_read_content?(admin)
            assert_equal true, @exam.can_read_content?(users(:main_staff))
          end

          it 'forbids students whose exam session started from viewing
              assignment resources' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students whose exam session has not started from viewing
              assignment resources' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students from viewing assignment resources if their exam
              attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids non-checked-in students from viewing assignment
              resources' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.can_read_content?(users(:deedee))
          end
        end

        describe 'deliverables not released, due date unscheduled' do
          before do
            @exam.update! scheduled: false, released_at: 1.day.from_now,
                grades_released: false
          end

          it 'lets only course staff view assignment resources' do
            assert_equal true, @exam.can_read_content?(admin)
            assert_equal true, @exam.can_read_content?(users(:main_staff))
          end

          it 'forbids students whose exam session started from viewing
              assignment resources' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students whose exam session has not started from viewing
              assignment resources' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids students from viewing assignment resources if their exam
              attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.can_read_content?(student)
          end

          it 'forbids non-checked-in students from viewing assignment
              resources' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.can_read_content?(users(:deedee))
          end
        end
      end
    end

    describe '#can_student_submit?' do
      describe 'assignment is released' do
        before { assert_equal true, assignment.released? }

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

      describe 'assignment is locked' do
        before do
          assignment.update! scheduled: true, released_at: 1.day.from_now
        end

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

      describe 'assignment is not scheduled' do
        before do
          assignment.update! scheduled: false, released_at: 1.day.ago
        end

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
      describe 'assignment is released' do
        before { assert_equal true, assignment.released? }

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

      describe 'assignment is locked' do
        before do
          assignment.update! scheduled: true, released_at: 1.day.from_now
        end

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

      describe 'assignment is not scheduled' do
        before do
          assignment.update! scheduled: false, released_at: 1.day.ago
        end

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
          golden = assignments(:project, :main_exam_3, :main_exam_2,
                               :assessment, :ps3, :main_exam, :ps2, :ps1)
          actual = courses(:main).assignments.by_deadline
          assert_equal golden, actual, actual.map(&:name)
        end
      end

      describe 'with_upcoming_deadline scope' do
        it 'returns assignments whose deadlines have not passed' do
          golden = assignments(:ps3, :project, :assessment, :main_exam,
                               :main_exam_2, :main_exam_3)
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

      describe 'past_due scope' do
        it 'returns assignments whose deadlines have passed' do
          golden = assignments(:ps1, :ps2)
          actual = courses(:main).assignments.past_due
          assert_equal golden.to_set, actual.to_set, actual.map(&:name)
        end
      end

      describe '.upcoming_for' do
        it 'returns released assignments the student can complete' do
          golden = assignments(:ps2, :assessment)
          actual = courses(:main).assignments.upcoming_for users(:dexter)
          assert_equal golden.to_set, actual.to_set, actual.map(&:name)
        end
      end

      describe '.default_due_at' do
        it 'returns the current hour' do
          assert_equal current_hour, Assignment.default_due_at
        end
      end

      describe '#default_due_at' do
        it 'returns the current hour' do
          assert_equal current_hour, assignment.default_due_at
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
        { name: 'PS Write-Up', description: 'Report', analyzer_attributes: {
          type: 'ProcAnalyzer', message_name: 'analyze_pdf', auto_grading: 0 } }
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

      describe 'assignment is released' do
        it 'returns all deliverables' do
          assert_equal true, assignment.released?
          actual = assignment.deliverables_for(any_user).sort_by(&:name)
          assert_equal golden, actual, actual.map(&:name)
        end
      end

      describe 'assignment has not been released' do
        before { assignment.update! released_at: 1.day.from_now }

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

  describe 'release cycle' do
    describe 'IsReleased concern' do
      describe '#act_on_reset_released_at' do
        describe 'release date has not been set yet' do
          before { assignment.update! released_at: nil }

          it 'updates the release date if :reset_released_at is false' do
            released_at = 1.day.from_now
            assignment.update! released_at: released_at,
                               reset_released_at: '0'
            assert_equal released_at, assignment.released_at
          end

          it 'overrides :released_at update if :reset_released_at is true' do
            assignment.update! released_at: 1.day.from_now,
                               reset_released_at: '1'
            assert_nil assignment.released_at
          end
        end

        describe 'release date has been set' do
          before { assert_not_nil assignment.released_at }

          it 'nullifies the release date if :reset_released_at is true' do
            assignment.update! reset_released_at: '1'
            assert_nil assignment.released_at
          end

          it 'overrides :released_at update if :reset_released_at is true' do
            assignment.update! released_at: 1.year.ago, reset_released_at: '1'
            assert_nil assignment.released_at
          end

          it 'does not change :released_at if :reset_released_at is false' do
            released_at = assignment.released_at
            assignment.update! reset_released_at: '0'
            assert_equal released_at, assignment.released_at
          end
        end
      end

      describe '.default_released_at' do
        it 'returns the current hour' do
          assert_equal current_hour, Assignment.default_released_at
        end
      end

      describe '#reset_released_at' do
        it 'returns true if the author has not chosen a release date' do
          assignment.update! released_at: nil
          assert_equal true, assignment.reload.reset_released_at
        end

        it 'returns false if the author has chosen a release date' do
          assert_not_nil assignment.released_at
          assert_equal false, assignment.reload.reset_released_at
        end
      end

      describe '#reset_released_at=' do
        it "sets :reset_released_at to true if the argument is '1'" do
          assert_equal false, assignment.reset_released_at
          assignment.update! reset_released_at: '1'
          assert_equal true, assignment.reload.reset_released_at
        end

        it "sets :reset_released_at to false if the argument is '0' and a
            new release date is provided" do
          assignment.update! released_at: nil
          assert_equal true, assignment.reset_released_at
          assignment.update! released_at: 1.day.from_now,
                             reset_released_at: '0'
          assert_equal false, assignment.reload.reset_released_at
        end
      end

      describe '#released_at_with_default' do
        it 'returns the release date, if it is not nil' do
          assert_not_nil assignment.released_at
          assert_equal assignment.released_at,
                       assignment.released_at_with_default
        end

        it 'returns the current hour, if the release date is nil' do
          assert_nil undecided_exam.released_at
          assert_equal current_hour, undecided_exam.released_at_with_default
        end
      end
    end

    it 'requires the release date to occur before the base deadline' do
      @assignment.released_at = @assignment.due_at + 1.day
      assert @assignment.invalid?
    end

    describe '#released?' do
      describe 'assignment has been scheduled' do
        before { assert_equal true, assignment.scheduled? }

        it 'returns false if the release date is nil' do
          assignment.update! released_at: nil
          assert_equal false, assignment.released?
        end

        it 'returns false if the deliverables release date has not passed' do
          assignment.update! released_at: 1.day.from_now
          assert_equal false, assignment.released?
        end

        it 'returns true if the deliverables have been released' do
          assert_operator assignment.released_at, :<, Time.current
          assert_equal true, assignment.released?
        end
      end

      describe 'assignment has not been scheduled' do
        before { @assignment.scheduled = false }

        it 'returns false if the deliverables have not been released' do
          @assignment.released_at = 1.day.from_now
          assert_equal false, @assignment.released?
        end

        it 'returns false if the deliverables have been released' do
          @assignment.released_at = 1.day.ago
          assert_equal false, @assignment.released?
        end
      end
    end

    describe '#released_for_student?' do
      describe 'assignment is a standard homework' do
        before { assert_nil assignment.exam }

        it 'is true for assignments whose deliverables have been released' do
          assignment.update! scheduled: true, released_at: 1.day.ago
          assert_equal true, assignment.released_for_student?(any_user)
          assert_equal true, assignment.released_for_student?(nil)
        end

        it 'is false for unscheduled assignments whose deliverables have been
            released' do
          assignment.update! scheduled: false, released_at: 1.day.ago
          assert_equal false, assignment.released_for_student?(admin)
          assert_equal false, assignment.released_for_student?(any_user)
          assert_equal false, assignment.released_for_student?(nil)
        end

        it 'is false for assignments whose deliverables have not been
            released' do
          assignment.update! scheduled: false, released_at: 1.day.from_now,
                             grades_released: false
          assert_equal false, assignment.released_for_student?(admin)
          assert_equal false, assignment.released_for_student?(any_user)
          assert_equal false, assignment.released_for_student?(nil)
        end

        it 'is false for unscheduled assignments whose deliverables have not
            been released' do
          assignment.update! scheduled: true, released_at: 1.day.from_now,
              grades_released: false
          assert_equal false, assignment.released_for_student?(admin)
          assert_equal false, assignment.released_for_student?(any_user)
          assert_equal false, assignment.released_for_student?(nil)
        end
      end

      describe 'assignment is an exam' do
        before do
          @exam = unreleased_exam
          @exam_attendance = @exam.exam.attendances.find_by(user: student)
          @exam_session = @exam_attendance.exam_session
          assert @exam.exam
        end

        describe 'deliverables released, due date scheduled' do
          before { @exam.update! scheduled: true, released_at: 1.day.ago }

          it 'is true for students whose exam session has started' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal true, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam session has not started yet' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students who have not signed up' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.released_for_student?(users(:deedee))
          end
        end

        describe 'deliverables released, due date unscheduled' do
          before { @exam.update! scheduled: false, released_at: 1.day.ago }

          it 'is false for students whose exam session has started' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam session has not started yet' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students who have not signed up' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.released_for_student?(users(:deedee))
          end
        end

        describe 'deliverables not released, due date scheduled' do
          before do
            @exam.update! scheduled: true, released_at: 1.day.from_now,
                grades_released: false
          end

          it 'is false for students whose exam session has started' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam session has not started yet' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students who have not signed up' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.released_for_student?(users(:deedee))
          end
        end

        describe 'deliverables not released, due date unscheduled' do
          before do
            @exam.update! scheduled: false, released_at: 1.day.from_now,
                grades_released: false
          end

          it 'is false for students whose exam session has started' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam session has not started yet' do
            @exam_session.update! starts_at: 1.hour.from_now,
                                  ends_at: 2.hours.from_now
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students whose exam attendance is unconfirmed' do
            @exam_session.update! starts_at: 1.hour.ago,
                                  ends_at: 1.hour.from_now
            @exam_attendance.update! confirmed: false
            assert_equal false, @exam.released_for_student?(student)
          end

          it 'is false for students who have not signed up' do
            assert_nil @exam.exam.attendances.find_by(user: users(:deedee))
            assert_equal false, @exam.released_for_student?(users(:deedee))
          end
        end
      end
    end

  end

  describe 'grade collection and releasing feature' do
    it 'rejects negative weights' do
      @assignment.weight = -5
      assert @assignment.invalid?
    end

    it 'must state whether or not students can view their grades' do
      @assignment.grades_released = nil
      assert @assignment.invalid?
    end

    describe 'grades have not been released yet' do
      before { assert_equal false, @assignment.grades_released }

      it 'does not require a release date' do
        @assignment.released_at = nil
        assert @assignment.valid?
      end
    end

    describe 'grades have been released' do
      before { @assignment.grades_released = true }

      it 'requires a release date' do
        @assignment.released_at = nil
        assert @assignment.invalid?
      end

      it 'requires the release date to have passed' do
        @assignment.released_at = 1.day.from_now
        @assignment.grades_released = true
        assert @assignment.invalid?
      end
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
          # ((100 + 80 + 10) / 3) * 1 + ((0 + 10 + 6) / 3) * 0 = 60
          assert_equal 60, assignment.average_score
        end
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
        assert_equal [3.0, 8.6],
            quality_metric.grades.where(subject: students).map(&:score).sort
        # ((10 + 70) / 2) * 1 + ((3 + 8.6) / 1) * 0 = 40
        assert_equal 40, assignment.recitation_score(section)
      end

      it 'returns nil if the assignment has no metrics' do
        assignment.metrics.destroy_all
        assert_nil assignment.reload.recitation_score(section)
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
            # (((100 + 80 + 10) / 3 * 100 / 100) * 1 +
            #     ((0 + 10 + 6) / 3 * 100 / 10) * 0 = 60
            assert_equal 60, assignment.average_score_percentage
          end
        end
      end
    end
  end

  describe 'lifecycle' do
    describe '#ui_state_for' do
      describe 'not scheduled' do
        before do
          assignment.update! scheduled: false, released_at: 1.week.ago,
              due_at: 2.weeks.from_now, grades_released: false
        end

        it 'returns :draft' do
          assert_equal :draft, assignment.reload.ui_state_for(student)
        end
      end

      describe 'locked' do
        before do
          assignment.update! scheduled: true, released_at: 1.week.from_now,
              due_at: 2.weeks.from_now, grades_released: false
        end

        it 'returns :locked' do
          assert_equal :locked, assignment.reload.ui_state_for(student)
        end
      end

      describe 'deliverables have been released' do
        before { assert_operator assignment.released_at, :<, Time.current }

        describe 'grades not ready yet' do
          before { assert_equal false, assignment.grades_released? }

          describe 'deadline has not passed yet for the user' do
            before do
              assert_equal false, assignment.deadline_passed_for?(student)
            end

            it 'returns :unlocked' do
              assert_equal :unlocked, assignment.ui_state_for(student)
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
            assignment.update! due_at: 1.day.ago, grades_released: true
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

  describe 'exams' do
    describe '#enable_exam?' do
      it 'returns false for a new assignment record' do
        assert_equal false, @assignment.enable_exam?
      end

      it 'returns true if the assignment has an associated exam' do
        assert_not_nil unreleased_exam.exam
        assert_equal true, unreleased_exam.enable_exam?
      end
    end

    describe '#enable_exam=' do
      describe 'the assignment does not have an associated exam' do
        before { assert_nil @assignment.exam }

        it 'does not save :enable_exam to true if the user input is "1" but no
            exam attributes are also saved' do
          assert_equal false, @assignment.enable_exam
          @assignment.update! enable_exam: '1'
          assert_equal false, assignment.enable_exam
        end

        it 'saves :enable_exam to true if the user input is "1" and exam
            attributes are also saved' do
          assert_equal false, @assignment.enable_exam
          @assignment.update! enable_exam: '1',
              exam_attributes: { requires_confirmation: false }
          assert_equal true, @assignment.enable_exam
        end

        it 'does not change :enable_exam if the user input is "0"' do
          assert_equal false, @assignment.enable_exam
          @assignment.update! enable_exam: '0',
              exam_attributes: { requires_confirmation: false }
          assert_equal false, @assignment.enable_exam
        end
      end

      describe 'the assignment has an associated exam' do
        before { assert_not_nil unreleased_exam.exam }

      end
    end

    it 'destroys dependent records' do
      assert_not_nil unreleased_exam.exam

      unreleased_exam.destroy

      assert_nil Exam.find_by(assignment: unreleased_exam)
    end

    describe '#nullify_exam_if_not_enabled' do
      describe 'saving new assignments' do
        it 'saves a nested exam if :enable_exam is true' do
          params = { assignment: { enable_exam: '1', exam_attributes: {
            requires_confirmation: false } } }
          assert_nil @assignment.exam
          @assignment.update! params[:assignment]
          assert_not_nil @assignment.reload.exam
        end

        it 'rejects nested exams if :enable_exam is false' do
          params = { assignment: { enable_exam: '0', exam_attributes: {
            requires_confirmation: false } } }
          assert_nil @assignment.exam
          @assignment.update! params[:assignment]
          assert_nil @assignment.reload.exam
        end
      end

      describe 'updating existing assignments' do
        it 'saves nested exam and exam sessions if :enable_exam is true' do
          start_time = 1.week.from_now.round 0  # Remove sub-second information.
          params = { assignment: { enable_exam: '1', exam_attributes: {
            requires_confirmation: false, exam_sessions_attributes: [{
            name: 'Rm 1, 2x time', starts_at: start_time,
            ends_at: start_time + 2.hours, capacity: 2 }]
          } } }
          assert_nil assignment.exam
          assignment.update! params[:assignment]
          assert_not_nil assignment.reload.exam
          assert_equal start_time, assignment.exam.exam_sessions.last.starts_at
        end

        it 'rejects nested exams if :enable_exam is false' do
          params = { assignment: { enable_exam: '0', exam_attributes: {
            requires_confirmation: false } } }
          assert_nil assignment.exam
          assignment.update! params[:assignment]
          assert_nil assignment.reload.exam
        end
      end
    end
  end

  describe 'Submittable concern' do
    describe '#student_submissions' do
      it 'does not count staff submissions' do
        assert_equal 6, assignment.submissions.length
        assert_equal 5, assignment.student_submissions.length
      end
    end
  end
end
