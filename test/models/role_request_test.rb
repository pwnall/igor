require 'test_helper'

describe RoleRequest do
  fixtures :users, :courses, :roles, :role_requests

  before do
    @request = RoleRequest.new user: users(:inactive), name: 'staff',
                               course: courses(:main)
  end

  it 'validates the setup request' do
    assert @request.valid?
  end

  it 'requires a user' do
    @request.user = nil
    assert_equal false, @request.valid?
  end

  it 'requires a name' do
    @request.name = nil
    assert_equal false, @request.valid?
  end

  it 'rejects invalid names' do
    @request.name = 'invalid'
    assert_equal false, @request.valid?
  end

  it 'requires a course on course-specific role' do
    @request.name = 'staff'
    @request.course = nil
    assert_equal false, @request.valid?
  end

  it 'rejects a course on site-wide role' do
    @request.name = 'admin'
    @request.course = courses(:main)
    assert_equal false, @request.valid?
  end

  it 'validates for a course-specific role' do
    @request.name = 'staff'
    @request.course = courses(:main)
    assert @request.valid?
  end

  it 'validates for a site-wide role' do
    @request.name = 'admin'
    @request.course = nil
    assert @request.valid?
  end

  it 'rejects site-wide duplicates' do
    @request.user = users(:solo)
    @request.name = 'admin'
    @request.course = nil
    assert_equal false, @request.valid?
  end

  it 'rejects course-specific duplicates' do
    @request.user = users(:dexter)
    @request.name = 'grader'
    @request.course = courses(:main)
    assert_equal false, @request.valid?
  end

  describe '#approve' do
    describe 'for site-wide roles' do
      it 'creates a Role when necessary' do
        assert_equal false, Role.has_entry?(users(:solo), 'admin')
        role_requests(:solo_wants_to_admin).approve
        assert_equal true, Role.has_entry?(users(:solo), 'admin')
      end

      it "doesn't crash if the Role exists" do
        assert_equal false, Role.has_entry?(users(:solo), 'admin')
        role_requests(:solo_wants_to_admin).approve
        assert_equal true, Role.has_entry?(users(:solo), 'admin')
        role_requests(:solo_wants_to_admin).approve
        assert_equal true, Role.has_entry?(users(:solo), 'admin')
      end
    end

    describe 'for course-specific roles' do
      it 'creates a Role when necessary' do
        assert_equal false, Role.has_entry?(users(:dexter), 'grader',
                                            courses(:main))
        role_requests(:dexter_wants_to_grade).approve
        assert_equal true, Role.has_entry?(users(:dexter), 'grader',
                                           courses(:main))
      end

      it "doesn't crash if the Role exists" do
        assert_equal false, Role.has_entry?(users(:dexter), 'grader',
                                            courses(:main))
        role_requests(:dexter_wants_to_grade).approve
        assert_equal true, Role.has_entry?(users(:dexter), 'grader',
                                           courses(:main))
        role_requests(:dexter_wants_to_grade).approve
        assert_equal true, Role.has_entry?(users(:dexter), 'grader',
                                           courses(:main))
      end
    end
  end
end

