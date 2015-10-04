require 'test_helper'

class MenuHelperTest < ActionView::TestCase
  include MenuHelper

  describe '#menu_type' do
    describe 'no course currently selected' do
      it 'returns the admin view for site admins' do
        assert_match /admin/, menu_type(users(:admin), nil)
      end

      it 'returns the guided view for users without a role' do
        assert_match /guided/, menu_type(users(:inactive), nil)
      end
    end

    describe 'a course is currently selected' do
      it 'returns the admin view for site admins' do
        assert_match /admin/, menu_type(users(:admin), courses(:main))
      end

      it 'returns the student view for students registered for the course' do
        assert_match /student/, menu_type(users(:dexter), courses(:main))
        assert_match /guided/, menu_type(users(:dexter), courses(:not_main))
      end

      it 'returns the staff view for course admins' do
        assert_match /staff/, menu_type(users(:main_staff), courses(:main))
        assert_match /guided/, menu_type(users(:main_staff), courses(:not_main))
      end

      it 'returns the grader view for course graders' do
        assert_match /grader/, menu_type(users(:main_grader), courses(:main))
        assert_match /guided/, menu_type(users(:main_grader),
                                         courses(:not_main))
      end
    end
  end
end
