require 'test_helper'

class GradesControllerTest < ActionController::TestCase
  describe 'authenticated as a registered student' do
    before { set_session_current_user users(:dexter) }

    describe 'GET #index' do
      it "renders an index of the student's grades" do
        get :index, params: { course_id: courses(:main).to_param }
        assert_response :success
      end
    end

    describe 'all actions except GET #index' do
      let(:params) { { course_id: courses(:main).to_param } }

      it 'forbids access to the page' do
        get :editor, params: params
        assert_response :forbidden

        post :create, params: params, xhr: true
        assert_response :forbidden

        get :request_missing, params: params
        assert_response :forbidden

        get :request_report, params: params
        assert_response :forbidden

        post :missing, params: params
        assert_response :forbidden

        post :report, params: params
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a staff' do
    before { set_session_current_user users(:main_staff) }

    describe 'GET #index (not intended for use by non-students)' do
      it "renders an index of the grader's grades" do
        get :index, params: { course_id: courses(:main).to_param }

        assert_response :success
        assert_select 'h2', '6.006 Grades'
      end
    end

    describe 'GET #editor' do
      let(:selected_assignment_value) do
        'form select#assignment_id>option[selected="selected"][value=?]'
      end

      describe 'pass the id of a specific assignment' do
        it 'opens the grade editor to the given assignment' do
          query_assignment = assignments(:project)
          get :editor, params: { course_id: courses(:main).to_param,
              assignment_id: query_assignment.to_param }

          assert_response :success
          assert_select selected_assignment_value, query_assignment.to_param
        end
      end

      describe 'no assignment id passed' do
        describe 'there are assignments whose deadlines have passed' do
          it 'opens the grade editor to the most recently due assignment' do
            get :editor, params: { course_id: courses(:main).to_param }

            assert_response :success
            assert_select selected_assignment_value, assignments(:ps2).to_param
          end
        end

        describe 'no assignment deadlines have passed yet' do
          it 'opens the grade editor to the last assignment' do
            courses(:main).assignments.joins(:deadline).each do |assignment|
              assignment.update due_at: 1.year.from_now
            end

            get :editor, params: { course_id: courses(:main).to_param }

            assert_response :success
            assert_select selected_assignment_value,
                          courses(:main).assignments.last.to_param
          end

          it 'renders a blank editor if no assignments exist' do
            Assignment.destroy_all
            get :editor, params: { course_id: courses(:main).to_param }

            assert_response :success
            assert_select 'p', 'No assignments defined.'
          end
        end
      end
    end

    describe 'XHR POST #create' do
      let(:student) { users(:dexter) }
      let(:metric) { assignment_metrics(:assessment_overall) }
      let(:params) do
        { course_id: courses(:main).to_param, grade: {
          subject_id: student.to_param, subject_type: 'User',
          metric_id: metric.to_param, score: '4.0' } }
      end

      describe 'enter a new score' do
        before { Grade.where(subject: student, metric: metric).destroy_all }

        it 'creates a new grade' do
          assert_difference 'Grade.count' do
            post :create, params: params, xhr: true
          end
          assert_equal 4.0, Grade.last.score
        end

        it 'renders the new score in the input field' do
          post :create, params: params, xhr: true
          assert_response :success
          assert_select "input[name='score'][value=?]", '4.0'
        end
      end

      describe 'change an existing score' do
        it 'updates the score of the grade' do
          grade = Grade.find_by subject: student, metric: metric
          assert_equal 70.0, grade.score
          post :create, params: params, xhr: true

          assert_equal 4.0, grade.reload.score
        end

        it 'renders the updated score in the input field' do
          post :create, params: params, xhr: true
          assert_response :success
          assert_select "input[name='score'][value=?]", '4.0'
        end
      end

      describe 'enter an invalid score value' do
        before { params[:grade][:score] = 'Not a number' }

        it 'does not change an existing grade' do
          grade = Grade.find_by subject: student, metric: metric
          assert_equal 70.0, grade.score

          assert_no_difference 'Grade.count' do
            post :create, params: params, xhr: true
          end
          assert_equal 70.0, grade.reload.score
        end

        it 'responds with a :not_acceptable header' do
          post :create, params: params, xhr: true
          assert_response :not_acceptable
        end
      end

      describe 'delete an existing score' do
        before { params[:grade][:score] = '' }

        it 'destroys the grade' do
          assert_not_nil Grade.find_by(subject: student, metric: metric)
          assert_difference 'Grade.count', -1 do
            post :create, params: params, xhr: true
          end
        end

        it 'renders an empty input field' do
          post :create, params: params, xhr: true

          assert_response :success
          assert_select "input[name='score'][value=?]", /.+/, false
        end
      end
    end

    describe 'GET #request_missing' do
      it 'renders the page for computing missing grades' do
        get :request_missing, params: { course_id: courses(:main).to_param }

        assert_response :success
        assert_select 'h2', 'Compute Missing Grades'
      end
    end

    describe 'GET #request_report' do
      it 'renders the page for downloading a grade report' do
        get :request_report, params: { course_id: courses(:main).to_param }

        assert_response :success
        assert_select 'h2', 'Report grades'
      end
    end

    describe 'POST #missing' do
      let(:selected_assignment_value) do
        'select#filter_aid option[selected="selected"][value=?]'
      end

      it 'renders the missing grades for the selected assignment' do
        query_assignment = assignments(:assessment)
        grades(:dexter_assessment_overall).destroy
        grades(:deedee_assessment_quality).destroy
        post :missing, params: { course_id: courses(:main).to_param,
            filter_aid: query_assignment.id }

        assert_response :success
        assert_select selected_assignment_value, query_assignment.id.to_s
        assert_select '.full_section tr', 2
      end
    end

    describe 'POST #report' do
      it 'renders the grade report' do
        get :report, params: { filter_aid: '', sort_by: 'name', name_by: 'name',
            use_weights: 'on', histogram_step: 10,
            course_id: courses(:main).to_param }

        assert_match /GRADES/, @response.body
        assert_equal "default-src 'none'",
            @response.headers['Content-Security-Policy']
        assert_match /inline/, @response.headers['Content-Disposition']
        assert_match /csv/, @response.headers['Content-Type']
      end
    end
  end

  describe 'authenticated as a grader' do
    before { set_session_current_user users(:main_grader) }

    describe 'GET #index (not intended for use by non-students)' do
      it "renders an index of the grader's grades" do
        get :index, params: { course_id: courses(:main).to_param }

        assert_response :success
        assert_select 'h2', '6.006 Grades'
      end
    end

    describe 'GET #editor' do
      let(:selected_assignment_value) do
        'form select#assignment_id>option[selected="selected"][value=?]'
      end

      describe 'pass the id of a specific assignment' do
        it 'opens the grade editor to the given assignment' do
          query_assignment = assignments(:project)
          get :editor, params: { course_id: courses(:main).to_param,
              assignment_id: query_assignment.to_param }

          assert_response :success
          assert_select selected_assignment_value, query_assignment.to_param
        end
      end
    end

    describe 'XHR POST #create' do
      let(:student) { users(:dexter) }
      let(:metric) { assignment_metrics(:assessment_overall) }
      let(:params) do
        { course_id: courses(:main).to_param, grade: {
          subject_id: student.to_param, subject_type: 'User',
          metric_id: metric.to_param, score: '4.0' } }
      end

      describe 'enter a new score' do
        before { Grade.where(subject: student, metric: metric).destroy_all }

        it 'creates a new grade' do
          assert_difference 'Grade.count' do
            post :create, params: params, xhr: true
          end
          assert_equal 4.0, Grade.last.score
        end

        it 'renders the new score in the input field' do
          post :create, params: params, xhr: true
          assert_response :success
          assert_select "input[name='score'][value=?]", '4.0'
        end
      end
    end

    describe 'GET #request_missing' do
      it 'bounces the user' do
        get :request_missing, params: { course_id: courses(:main).to_param }

        assert_response :forbidden
      end
    end

    describe 'GET #request_report' do
      it 'bounces the user' do
        get :request_report, params: { course_id: courses(:main).to_param }

        assert_response :forbidden
      end
    end

    describe 'POST #missing' do
      it 'bounces the user' do
        query_assignment = assignments(:assessment)
        post :missing, params: { course_id: courses(:main).to_param,
            filter_aid: query_assignment.id }

        assert_response :forbidden
      end
    end

    describe 'POST #report' do
      it 'bounces the user' do
        get :report, params: { filter_aid: '', sort_by: 'name', name_by: 'name',
            use_weights: 'on', histogram_step: 10,
            course_id: courses(:main).to_param }

        assert_response :forbidden
      end
    end
  end
end
