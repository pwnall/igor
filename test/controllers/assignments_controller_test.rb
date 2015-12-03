require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  let(:released_assignment) { assignments(:ps1) }
  let(:grades_unreleased_assignment) { assignments(:ps3) }
  let(:unreleased_assignment) { assignments(:main_exam) }
  let(:undecided_assignment) { assignments(:main_exam_2) }
  let(:member_params) do
    { course_id: courses(:main).to_param, id: @assignment.to_param }
  end

  describe 'authenticated as a registered student' do
    before { set_session_current_user users(:dexter) }

    describe 'GET #index' do
      it 'renders all assignments with released grades/deliverables' do
        get :index, params: { course_id: courses(:main).to_param }
        assert_response :success
        released_assignments = courses(:main).assignments.select(&:released?)
        assert_select 'li.submission-dashboard', released_assignments.count
      end
    end
  end

  describe 'authenticated as a course editor' do
    before { set_session_current_user users(:main_staff) }

    describe 'GET #index' do
      it 'renders all assignments' do
        get :index, params: { course_id: courses(:main).to_param }
        assert_response :success
        assert_select 'li.submission-dashboard',
                      courses(:main).assignments.count
      end
    end

    describe 'PATCH #release' do
      describe 'the release date is undecided' do
        before { @assignment = undecided_assignment }

        it 'sets the release date to the current time' do
          assert_nil @assignment.released_at
          patch :release, params: member_params
          assert_in_delta Time.current, @assignment.reload.released_at, 1.hour
        end
      end

      describe 'the release date has not passed yet' do
        before { @assignment = unreleased_assignment }

        it 'sets the release date to the current time' do
          assert_in_delta 1.day.from_now, @assignment.released_at, 1.hour
          patch :release, params: member_params
          assert_in_delta Time.current, @assignment.reload.released_at, 1.hour
        end
      end
    end

    describe 'PATCH #unrelease' do
      describe 'grades have already been released' do
        before { @assignment = released_assignment }

        it 'sets the release date to be undecided' do
          assert_in_delta 3.weeks.ago, @assignment.released_at, 1.hour
          patch :unrelease, params: member_params
          assert_nil @assignment.reload.released_at
        end

        it 'unreleasees the grades for this assignment' do
          assert_equal true, @assignment.grades_released
          patch :unrelease, params: member_params
          assert_equal false, @assignment.reload.grades_released
        end
      end
    end

    describe 'PATCH #release_grades' do
      describe 'the release date is undecided' do
        before { @assignment = undecided_assignment }

        it 'sets the release date to the current time' do
          assert_nil @assignment.released_at
          patch :release_grades, params: member_params
          assert_in_delta Time.current, @assignment.reload.released_at, 1.hour
        end

        it 'releasees the grades' do
          assert_equal false, @assignment.grades_released?
          patch :release_grades, params: member_params
          assert_equal true, @assignment.reload.grades_released?
        end
      end

      describe 'the release date has not passed yet' do
        before { @assignment = unreleased_assignment }

        it 'sets the release date to the current time' do
          assert_in_delta 1.day.from_now, @assignment.released_at, 1.hour
          patch :release_grades, params: member_params
          assert_in_delta Time.current, @assignment.reload.released_at, 1.hour
        end

        it 'releasees the grades' do
          assert_equal false, @assignment.grades_released?
          patch :release_grades, params: member_params
          assert_equal true, @assignment.reload.grades_released?
        end
      end

      describe 'the assignment has been released_assignment' do
        before { @assignment = grades_unreleased_assignment }

        it 'does not change the release date' do
          assert_no_difference '@assignment.reload.released_at' do
            patch :release_grades, params: member_params
          end
        end

        it 'releasees the grades' do
          assert_equal false, @assignment.grades_released?
          patch :release_grades, params: member_params
          assert_equal true, @assignment.reload.grades_released?
        end
      end
    end
  end
end
