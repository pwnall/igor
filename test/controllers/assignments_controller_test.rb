require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  let(:released_assignment) { assignments(:ps1) }
  let(:grades_unreleased_assignment) { assignments(:ps3) }
  let(:unreleased_assignment) { assignments(:main_exam) }
  let(:undecided_assignment) { assignments(:main_exam_2) }
  let(:scheduled_unreleased_exam) { assignments(:main_exam_3) }
  let(:member_params) do
    { course_id: courses(:main).to_param, id: assignment.to_param }
  end
  before do
    @year_due = Time.current.year + 1
    @month_due = '04'
    @day_due = '02'
    @hour_due = '16'
  end
  let(:date_param) do
    { due_at: "#{@year_due}-#{@month_due}-#{@day_due}T#{@hour_due}:00:00" }
  end
  let(:create_params) do
    { course_id: courses(:main).to_param, assignment: { name: 'New Pset',
      reset_released_at: 1, weight: 1, enable_exam: 0,
      author_exuid: users(:main_staff).to_param }.merge(date_param) }
  end

  describe 'authenticated as a registered student' do
    before { set_session_current_user users(:dexter) }

    describe 'GET #index' do
      it 'renders all scheduled assignments' do
        get :index, params: { course_id: courses(:main).to_param }
        assert_response :success
        released_assignments = courses(:main).assignments.select(&:scheduled?)
        assert_select 'li.submission-dashboard', released_assignments.count
      end
    end

    describe 'GET #show' do
      describe 'assignment not scheduled' do
        describe 'assignment has not been released' do
          let(:assignment) { undecided_assignment }

          it 'bounces students' do
            get :show, params: member_params
            assert_response :forbidden
          end
        end

        describe 'assignment has been released' do
          let(:assignment) { grades_unreleased_assignment }

          it 'bounces students' do
            get :show, params: member_params
            assert_response :forbidden
          end
        end
      end

      describe 'assignment has been scheduled' do
        describe 'assignment has not been released' do
          let(:assignment) { scheduled_unreleased_exam }
          let(:deliverable) { assignment.deliverables.first }

          it 'renders the student submission view' do
            get :show, params: member_params
            assert_response :success
            assert_select 'section.submission-dashboard-container'
          end

          it 'includes the exam sessions tab' do
            assert_not_nil assignment.exam
            html_panel_id = 'exam-sessions-panel'
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']"
            assert_select ".tabs-panel##{html_panel_id}"
          end

          it 'omits the deliverables tabs' do
            assert_not_nil deliverable
            html_panel_id = @controller.deliverable_panel_id deliverable
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']", false
            assert_select ".tabs-panel##{html_panel_id}", false
          end
        end

        describe 'assignment has been released' do
          let(:assignment) { released_assignment }
          let(:deliverable) { assignment.deliverables.first }

          it 'renders the student submission view' do
            get :show, params: member_params
            assert_response :success
            assert_select 'section.submission-dashboard-container'
          end

          it 'includes the deliverables tabs' do
            assert_not_nil deliverable
            html_panel_id = @controller.deliverable_panel_id deliverable
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']"
            assert_select ".tabs-panel##{html_panel_id}"
          end
        end

        describe 'assignment with exam has been released' do
          let(:assignment) { scheduled_unreleased_exam }
          let(:deliverable) { assignment.deliverables.first }
          before { assignment.update! released_at: 1.day.ago }

          it 'renders the student submission view' do
            get :show, params: member_params
            assert_response :success
            assert_select 'section.submission-dashboard-container'
          end

          it 'includes the exam sessions tab' do
            assert_not_nil assignment.exam
            html_panel_id = 'exam-sessions-panel'
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']"
            assert_select ".tabs-panel##{html_panel_id}"
          end

          it 'omits the deliverables tabs' do
            assert_not_nil deliverable
            html_panel_id = @controller.deliverable_panel_id deliverable
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']", false
            assert_select ".tabs-panel##{html_panel_id}", false
          end
        end
      end

      describe 'signed up for an ongoing session' do
        let(:assignment) { unreleased_assignment }
        let(:deliverable) { assignment.deliverables.first }
        let(:exam_attendance) do
          assignment.exam.attendances.find_by user: session_current_user
        end
        let(:exam_session) { exam_attendance.exam_session }

        before do
          exam_session.update! starts_at: 1.hour.ago, ends_at: 1.hour.from_now
        end

        describe 'in a released exam' do
          before { assignment.update! released_at: 1.day.ago }

          it 'renders the student submission view' do
            get :show, params: member_params
            assert_response :success
            assert_select 'section.submission-dashboard-container'
          end

          it 'includes the exam sessions tab' do
            assert_not_nil assignment.exam
            html_panel_id = 'exam-sessions-panel'
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']"
            assert_select ".tabs-panel##{html_panel_id}"
          end

          it 'includes the deliverables tabs' do
            assert_not_nil deliverable
            html_panel_id = @controller.deliverable_panel_id deliverable
            get :show, params: member_params
            assert_response :success
            assert_select ".tabs-title > a[href='##{html_panel_id}']"
            assert_select ".tabs-panel##{html_panel_id}"
          end
        end
      end
    end

    describe 'all actions except #index and #show' do
      let(:assignment) { unreleased_assignment }

      it 'forbids access to the page' do
        get :dashboard, params: member_params
        assert_response :forbidden

        get :new, params: { course_id: courses(:main).to_param }
        assert_response :forbidden

        get :edit, params: member_params
        assert_response :forbidden

        post :create, params: { course_id: courses(:main).to_param }
        assert_response :forbidden

        patch :update, params: member_params
        assert_response :forbidden

        delete :destroy, params: member_params
        assert_response :forbidden

        patch :schedule, params: member_params
        assert_response :forbidden

        patch :deschedule, params: member_params
        assert_response :forbidden

        patch :release, params: member_params
        assert_response :forbidden

        patch :unrelease, params: member_params
        assert_response :forbidden

        patch :release_grades, params: member_params
        assert_response :forbidden
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

    describe 'GET #new' do
      it 'renders the new assignment form' do
        get :new, params: { course_id: courses(:main).to_param }
        assert_response :success
        assert_select 'form.new-assignment-form'
      end
    end

    describe 'GET #edit' do
      let(:assignment) { unreleased_assignment }

      describe 'the assignment does not have an associated exam record' do
        before { assignment.exam.destroy! }

        it 'renders the assignment builder page' do
          get :edit, params: member_params
          assert_response :success
          assert_select 'form.edit-assignment-form'
        end
      end

      describe 'the assignment has an associated exam record' do
        before { assert_not_nil assignment.exam }

        it 'renders the assignment builder page' do
          get :edit, params: member_params
          assert_response :success
          assert_select 'form.edit-assignment-form'
        end
      end
    end

    describe 'POST #create' do
      describe 'the user entered valid form fields' do
        it 'creates a new assignment' do
          assert_difference 'Assignment.count' do
            post :create, params: create_params
          end
          new_assignment = Assignment.last
          assert_equal courses(:main), new_assignment.course
          assert_equal false, new_assignment.scheduled
          assert_equal false, new_assignment.grades_released
        end

        it 'redirects to the full assignment builder form' do
          post :create, params: create_params
          new_assignment = Assignment.last
          assert_redirected_to edit_assignment_url(new_assignment,
              course_id: new_assignment.course)
        end
      end

      describe 'the user entered an invalid form field' do
        before { create_params[:assignment][:author_exuid] = nil }

        it 'does not create a new assignment' do
          assert_no_difference 'Assignment.count' do
            post :create, params: create_params
          end
          assert_response :success
        end

        it 're-renders the basic assignment form' do
          post :create, params: create_params
          assert_response :success
          assert_select 'form.new-assignment-form'
        end
      end
    end

    describe 'PATCH #update' do
      let(:member_params) do
        { id: released_assignment.to_param, course_id: courses(:main).to_param,
          assignment: { name: 'New name' } }
      end

      describe 'the user entered valid form fields' do
        it 'updates the assignment attribute values' do
          assert_equal 'PSet 1', released_assignment.name
          patch :update, params: member_params
          assert_equal 'New name', released_assignment.reload.name
        end

        it 'redirects to the assignment dashboard' do
          patch :update, params: member_params
          assert_redirected_to dashboard_assignment_url(released_assignment,
              course_id: released_assignment.course)
        end
      end

      describe 'the user entered an invalid form field' do
        before { member_params[:assignment][:name] = '' }

        it 'does not change assignment attribute values' do
          original_name = released_assignment.name
          patch :update, params: member_params
          assert_equal original_name, released_assignment.reload.name
        end

        it 're-renders the extended assignment builder form' do
          patch :update, params: member_params
          assert_response :success
          assert_select 'form.edit-assignment-form'
        end
      end
    end

    describe 'PATCH #schedule' do
      describe 'the release date is undecided' do
        let(:assignment) { undecided_assignment }

        it 'does not change the release time' do
          assert_equal false, assignment.scheduled?
          assert_nil assignment.released_at

          patch :schedule, params: member_params

          assert_equal true, assignment.reload.scheduled?
          assert_nil assignment.released_at
        end
      end

      describe 'the release date has not passed yet' do
        let(:assignment) { unreleased_assignment }

        it 'does not change the release time and does not release grades' do
          assignment.update! scheduled: false
          assert_equal false, assignment.grades_released?
          old_released_at = assignment.released_at

          patch :schedule, params: member_params

          assert_equal true, assignment.reload.scheduled?
          assert_equal old_released_at, assignment.released_at
          assert_equal false, assignment.grades_released?
        end
      end

      describe 'the release date has passed' do
        let(:assignment) { released_assignment }

        it 'does not change the release time' do
          assignment.update! scheduled: false, grades_released: false
          old_released_at = assignment.released_at

          patch :schedule, params: member_params

          assert_equal true, assignment.reload.scheduled?
          assert_equal old_released_at, assignment.released_at
        end
      end
    end

    describe 'PATCH #deschedule' do
      describe 'the release date is undecided' do
        let(:assignment) { undecided_assignment }

        it 'does not change the release time' do
          assignment.update! scheduled: true
          assert_nil assignment.released_at

          patch :deschedule, params: member_params

          assert_equal false, assignment.reload.scheduled?
          assert_nil assignment.released_at
        end
      end

      describe 'the release date has not passed yet' do
        let(:assignment) { unreleased_assignment }

        it 'does not change the release time' do
          assert_equal true, assignment.scheduled?
          assert_equal false, assignment.grades_released?
          old_released_at = assignment.released_at

          patch :deschedule, params: member_params

          assert_equal false, assignment.reload.scheduled?
          assert_equal old_released_at, assignment.released_at
          assert_equal false, assignment.grades_released?
        end
      end

      describe 'the grades have been released' do
        let(:assignment) { released_assignment }

        it 'pulls grades and does not change the release time' do
          assert_equal true, assignment.scheduled?
          assert_equal true, assignment.grades_released?
          old_released_at = assignment.released_at

          patch :deschedule, params: member_params

          assert_equal false, assignment.reload.scheduled?
          assert_equal old_released_at, assignment.released_at
          assert_equal false, assignment.grades_released?
        end
      end
    end

    describe 'PATCH #release' do
      describe 'the release date is undecided' do
        let(:assignment) { undecided_assignment }

        it 'sets the release date to the current time' do
          assert_nil assignment.released_at
          patch :release, params: member_params
          assert_in_delta Time.current, assignment.reload.released_at, 1.hour
          assert_equal true, assignment.scheduled?
        end
      end

      describe 'the release date has not passed yet' do
        let(:assignment) { unreleased_assignment }

        it 'sets the release date to the current time' do
          assert_in_delta 1.day.from_now, assignment.released_at, 1.hour
          patch :release, params: member_params
          assert_in_delta Time.current, assignment.reload.released_at, 1.hour
          assert_equal true, assignment.scheduled?
        end
      end

      describe 'the release date has passed' do
        let(:assignment) { released_assignment }

        it 'does not change the release date' do
          old_released_at = assignment.released_at
          assert_equal true, assignment.released?

          patch :release, params: member_params
          assert_equal old_released_at, assignment.reload.released_at
          assert_equal true, assignment.scheduled?
        end
      end
    end

    describe 'PATCH #unrelease' do
      describe 'grades have already been released' do
        let(:assignment) { released_assignment }

        it 'sets the release date to be undecided' do
          assert_in_delta 3.weeks.ago, assignment.released_at, 1.hour
          patch :unrelease, params: member_params
          assert_nil assignment.reload.released_at
        end

        it 'unreleases the grades for this assignment' do
          assert_equal true, assignment.grades_released?
          patch :unrelease, params: member_params
          assert_equal false, assignment.reload.grades_released?
        end

        it 'does not de-schedule the assignment' do
          assert_equal true, assignment.scheduled?
          patch :unrelease, params: member_params
          assert_equal true, assignment.reload.scheduled?
        end
      end
    end

    describe 'PATCH #release_grades' do
      describe 'the release date is undecided' do
        let(:assignment) { undecided_assignment }

        it 'sets the release date to the current time' do
          assert_nil assignment.released_at
          patch :release_grades, params: member_params
          assert_in_delta Time.current, assignment.reload.released_at, 1.hour
        end

        it 'releases the grades' do
          assert_equal false, assignment.grades_released?
          patch :release_grades, params: member_params
          assert_equal true, assignment.reload.grades_released?
        end
      end

      describe 'the release date has not passed yet' do
        let(:assignment) { unreleased_assignment }

        it 'sets the release date to the current time' do
          assert_in_delta 1.day.from_now, assignment.released_at, 1.hour
          patch :release_grades, params: member_params
          assert_in_delta Time.current, assignment.reload.released_at, 1.hour
        end

        it 'releases the grades' do
          assert_equal false, assignment.grades_released?
          patch :release_grades, params: member_params
          assert_equal true, assignment.reload.grades_released?
        end
      end

      describe 'the assignment has been released_assignment' do
        let(:assignment) { grades_unreleased_assignment }

        it 'does not change the release date' do
          assert_no_difference 'assignment.reload.released_at' do
            patch :release_grades, params: member_params
          end
        end

        it 'releases the grades' do
          assert_equal false, assignment.grades_released?
          patch :release_grades, params: member_params
          assert_equal true, assignment.reload.grades_released?
        end
      end
    end
  end
end
