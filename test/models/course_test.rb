require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  before do
    @course = Course.new number: '1.234', title: 'Intro', email: 'a@mit.edu',
        email_on_role_requests: true, has_recitations: true, has_surveys: true,
        has_teams: true, ga_account: 'UA-19600078-3'
  end

  let(:course) { courses(:main) }

  it 'validates the setup course' do
    assert @course.valid?
  end

  it 'requires a course number' do
    @course.number = nil
    assert @course.invalid?
  end

  it 'rejects lengthy course numbers' do
    @course.number = '1' * 17
    assert @course.invalid?
  end

  it 'requires a title' do
    @course.title = nil
    assert @course.invalid?
  end

  it 'rejects lengthy titles' do
    @course.title = 'I' * 257
    assert @course.invalid?
  end

  it 'requires a staff contact e-mail' do
    @course.email = nil
    assert @course.invalid?
  end

  it 'rejects lengthy e-mails' do
    @course.email = 'a' * 64 + '@mit.edu'
    assert @course.invalid?
  end

  it 'requires a flag for emailing on role requests' do
    @course.email_on_role_requests = nil
    assert @course.invalid?
  end

  it 'requires a flag for having recitations' do
    @course.has_recitations = nil
    assert @course.invalid?
  end

  it 'accepts a positive integer max section size' do
    @course.section_size = 15
    assert @course.valid?
  end

  it 'rejects a negative integer max section size' do
    @course.section_size = -15
    assert @course.invalid?
  end

  it 'rejects a 0 max section size' do
    @course.section_size = 0
    assert @course.invalid?
  end

  it 'rejects a non-integer max section size' do
    @course.section_size = 18.2
    assert @course.invalid?
  end

  it 'requires a flag for homework surveys' do
    @course.has_surveys = nil
    assert @course.invalid?
  end

  it 'requires a flag for homework teams' do
    @course.has_teams = nil
    assert @course.invalid?
  end

  it 'requires a Google Analytics account ID' do
    @course.ga_account = nil
    assert @course.invalid?
  end

  it 'rejects a lengthy Google Analytics account ID' do
    @course.ga_account = 'U' * 33
    assert @course.invalid?
  end

  it 'destroys dependent records' do
    assert_not_empty course.registrations
    assert_not_empty course.prerequisites
    assert_not_empty course.assignments
    assert_not_empty course.recitation_sections
    assert_not_empty course.time_slots
    assert_not_empty course.roles
    assert_not_empty course.role_requests
    assert_not_empty course.surveys

    course.destroy

    assert_empty course.registrations.reload
    assert_empty course.prerequisites.reload
    assert_empty course.assignments.reload
    assert_empty course.recitation_sections.reload
    assert_empty course.time_slots.reload
    assert_empty course.roles.reload
    assert_empty course.role_requests.reload
    assert_empty course.surveys.reload
  end

  describe 'students' do
    describe '#students' do
      it 'returns only users currently enrolled in this course' do
        golden = users(:solo, :deedee, :dexter, :mandark)
        assert_equal golden, course.students.sort_by(&:name)
      end
    end
  end

  describe 'staff permissions' do
    describe '#is_staff?' do
      it 'returns true for staff members only' do
        assert_equal false, course.is_staff?(users(:dexter))
        assert_equal false, course.is_staff?(users(:robot))
        assert_equal false, course.is_staff?(users(:main_grader))
        assert_equal true, course.is_staff?(users(:main_staff))
        assert_equal false, course.is_staff?(users(:admin))
        assert_equal false, course.is_staff?(nil)
      end
    end

    describe '#is_grader?' do
      it 'returns true for graders only' do
        assert_equal false, course.is_grader?(users(:dexter))
        assert_equal false, course.is_grader?(users(:robot))
        assert_equal true, course.is_grader?(users(:main_grader))
        assert_equal false, course.is_grader?(users(:main_staff))
        assert_equal false, course.is_grader?(users(:admin))
        assert_equal false, course.is_grader?(nil)
      end
    end

    describe '#can_edit?' do
      it 'returns true for staff members and admins only' do
        assert_equal false, course.can_edit?(users(:dexter))
        assert_equal false, course.can_edit?(users(:robot))
        assert_equal false, course.can_edit?(users(:main_grader))
        assert_equal true, course.can_edit?(users(:main_staff))
        assert_equal true, course.can_edit?(users(:admin))
        assert_equal false, course.can_edit?(nil)
      end
    end

    describe '#can_grade?' do
      it 'returns true for all users except students' do
        assert_equal false, course.can_grade?(users(:dexter))
        assert_equal true, course.can_grade?(users(:robot))
        assert_equal true, course.can_grade?(users(:main_grader))
        assert_equal true, course.can_grade?(users(:main_staff))
        assert_equal true, course.can_grade?(users(:admin))
        assert_equal false, course.can_grade?(nil)
      end
    end

    describe '#staff' do
      it 'returns all users with the staff role for only this course' do
        assert_equal [users(:main_staff)], course.staff
      end
    end

    describe '#graders' do
      it 'returns all users with the grader role for only this course' do
        assert_equal [users(:main_grader)], course.graders
      end
    end
  end

  describe 'homework' do
    describe '.most_relevant_assignment_for_graders' do
      describe 'there are assignments whose deadlines have passed' do
        it 'retrieves the assignment that was due most recently' do
          assert_equal assignments(:ps3),
                       course.most_relevant_assignment_for_graders
        end
      end

      describe 'no assignment deadlines have passed yet' do
        it 'retrieves the assignment that was last created' do
          courses(:main).assignments.joins(:deadline).each do |assignment|
            assignment.update due_at: 1.year.from_now
          end

          assert_equal Assignment.last,
                       course.most_relevant_assignment_for_graders
        end
      end
    end

    describe '#assignments_for' do
      describe 'the given user is a site or course admin' do
        it 'returns all assignments for the course, ordered by deadline' do
          golden = assignments(:project, :ps3, :assessment, :ps2,  :ps1)
          actual = course.assignments_for users(:admin)
          assert_equal golden, actual, actual.map(&:name)
        end
      end

      describe 'the given user is not a site or course admin' do
        it 'returns assignments with released deliverables/grades, ordered by
            deadline' do
          golden = assignments(:project, :assessment, :ps1)
          actual = course.assignments_for users(:dexter)
          assert_equal golden, actual, actual.map(&:name)
        end
      end
    end
  end

  describe 'surveys' do
    describe '#surveys_for' do
      describe 'the given user is a site or course admin' do
        it 'returns all surveys in the course, ordered by deadline' do
          golden = surveys(:lab, :project, :ps1)
          actual = course.surveys_for users(:main_staff)
          assert_equal golden, actual
        end
      end

      describe 'the given user is a student registered for the course' do
        it 'returns all published surveys in the course, ordered by deadline' do
          assert_includes users(:dexter).registered_courses, course
          golden = surveys(:lab, :ps1)
          actual = course.surveys_for users(:dexter)
          assert_equal golden, actual
        end
      end

      describe 'the given user is not registered for the course' do
        it 'returns no surveys' do
          assert_not_includes users(:inactive).registered_courses, course
          assert_empty course.surveys_for users(:inactive)
        end
      end
    end
  end
end
