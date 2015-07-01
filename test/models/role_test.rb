require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :users, :courses, :roles

  before do
    @role = Role.new user: users(:solo), name: 'staff', course: courses(:main)
  end

  it 'validates the setup role' do
    assert @role.valid?
  end

  it 'requires a user' do
    @role.user = nil
    assert_equal false, @role.valid?
  end

  it 'requires a name' do
    @role.name = nil
    assert_equal false, @role.valid?
  end

  it 'rejects invalid names' do
    @role.name = 'invalid'
    assert_equal false, @role.valid?
  end

  it 'requires a course on course-specific role' do
    @role.name = 'staff'
    @role.course = nil
    assert_equal false, @role.valid?
  end

  it 'rejects a course on site-wide role' do
    @role.name = 'admin'
    @role.course = courses(:main)
    assert_equal false, @role.valid?
  end

  it 'validates for a course-specific role' do
    @role.name = 'staff'
    @role.course = courses(:main)
    assert @role.valid?
  end

  it 'validates for a site-wide role' do
    @role.name = 'admin'
    @role.course = nil
    assert @role.valid?
  end

  it 'rejects site-wide duplicates' do
    @role.user = users(:admin)
    @role.name = 'admin'
    @role.course = nil
    assert_equal false, @role.valid?
  end

  it 'rejects course-specific duplicates' do
    @role.user = users(:main_grader)
    @role.name = 'grader'
    @role.course = courses(:main)
    assert_equal false, @role.valid?
  end

  describe '#has_entry?' do
    it 'works for site-wide roles' do
      assert_equal true, Role.has_entry?(users(:admin), 'admin')
      assert_equal false, Role.has_entry?(users(:dexter), 'admin')
    end

    it 'works for course-specific roles' do
      assert_equal true, Role.has_entry?(users(:main_grader), 'grader',
                                         courses(:main))
      assert_equal false, Role.has_entry?(users(:dexter), 'grader',
                                          courses(:main))
    end

    it 'fails gracefully with bad course args' do
      assert_equal false, Role.has_entry?(users(:admin), 'admin',
                                          courses(:main))
      assert_equal false, Role.has_entry?(users(:main_grader), 'grader')
    end
  end

  describe '#grant' do
    describe 'for site-wide roles' do
      it 'creates a Role when necessary' do
        assert_equal false, Role.has_entry?(users(:dexter), 'admin')
        Role.grant users(:dexter), 'admin'
        assert_equal true, Role.has_entry?(users(:dexter), 'admin')
      end

      it "doesn't crash if the Role exists" do
        assert_equal true, Role.has_entry?(users(:admin), 'admin')
        Role.grant users(:admin), 'admin'
        assert_equal true, Role.has_entry?(users(:admin), 'admin')
      end
    end

    describe 'for course-specific roles' do
      it 'creates a Role when necessary' do
        assert_equal false, Role.has_entry?(users(:dexter), 'grader',
                                            courses(:main))
        Role.grant users(:dexter), 'grader', courses(:main)
        assert_equal true, Role.has_entry?(users(:dexter), 'grader',
                                           courses(:main))
      end

      it "doesn't crash if the Role exists" do
        assert_equal true, Role.has_entry?(users(:main_grader), 'grader',
                                           courses(:main))
        Role.grant users(:main_grader), 'grader', courses(:main)
        assert_equal true, Role.has_entry?(users(:main_grader), 'grader',
                                           courses(:main))
      end
    end
  end

  describe '#revoke' do
    describe 'for site-wide roles' do
      it 'destroys a Role when necessary' do
        assert_equal true, Role.has_entry?(users(:admin), 'admin')
        Role.revoke users(:admin), 'admin'
        assert_equal false, Role.has_entry?(users(:admin), 'admin')
      end

      it "doesn't crash if no Role exists" do
        assert_equal false, Role.has_entry?(users(:dexter), 'admin')
        Role.revoke users(:dexter), 'admin'
        assert_equal false, Role.has_entry?(users(:dexter), 'admin')
      end
    end

    describe 'for course-specific roles' do
      it 'destroys a Role when necessary' do
        assert_equal true, Role.has_entry?(users(:main_grader), 'grader',
                                           courses(:main))
        Role.revoke users(:main_grader), 'grader', courses(:main)
        assert_equal false, Role.has_entry?(users(:main_grader), 'grader',
                                            courses(:main))
      end

      it "doesn't crash if no Role exists" do
        assert_equal false, Role.has_entry?(users(:dexter), 'grader',
                                            courses(:main))
        Role.revoke users(:dexter), 'grader', courses(:main)
        assert_equal false, Role.has_entry?(users(:dexter), 'grader',
                                            courses(:main))
      end
    end
  end

end
