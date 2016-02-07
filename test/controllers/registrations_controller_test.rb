require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  let(:course) { courses(:main) }
  let(:member_params) do
    { course_id: course.to_param, id: @registration.to_param }
  end

  describe 'GET #show' do
    let(:recitation_name_h5) { 'h5.recitation-section-name' }

    describe 'course has recitation sections' do
      before { assert_equal true, course.has_recitations? }

      describe 'student has an assigned recitation section' do
        before do
          set_session_current_user users(:dexter)
          @registration = registrations(:dexter)
          assert @registration.recitation_section
        end

        it 'displays the name of the assigned recitation section' do
          get :show, params: member_params
          assert_response :success
          assert_select recitation_name_h5, 'R01 - 10-250 Main Staff'
        end
      end

      describe 'student was not assigned a recitation section' do
        before do
          set_session_current_user users(:mandark)
          @registration = registrations(:mandark)
          assert_nil @registration.recitation_section
        end

        it "displays the recitation section as 'Unassigned'" do
          get :show, params: member_params
          assert_response :success
          assert_select recitation_name_h5, 'Unassigned'
        end
      end
    end

    describe 'course does not use recitation sections' do
      before do
        course.update! has_recitations: false
        set_session_current_user users(:mandark)
        @registration = registrations(:mandark)
      end

      it 'renders the registration without the recitation section portion' do
        get :show, params: member_params
        assert_response :success
        assert_select 'section.recitation-section', false
      end
    end
  end
end
