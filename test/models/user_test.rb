require 'test_helper'

class UserTest < ActiveSupport::TestCase
  before do
    @user = User.new email: 'dvdjon@mit.edu', password: 'awesome',
        password_confirmation: 'awesome', profile_attributes: {
        name: 'Jon Johansen', nickname: 'dvdjon', university: 'MIT',
        department: 'EECS', year: 'G', athena_username: 'jon' }
  end

  let(:dexter) { users(:dexter) }
  let(:grader) { users(:main_grader) }
  let(:another_grader) { users(:main_grader_2) }
  let(:staff) { users(:main_staff) }
  let(:another_staff) { users(:main_staff_2) }
  let(:admin) { users(:admin) }
  let(:robot) { users(:robot) }
  let(:solo) { users(:solo) }
  let(:inactive) { users(:inactive) }

  it 'validates the setup user' do
    assert @user.valid?
  end

  ['costan@gmail.com', 'cos tan@gmail.com', 'costan@x@mit.edu',
   'costan@mitZedu'].each do |email|
    it "rejects invalid e-mail: #{email}" do
      @user.email = email
      assert @user.invalid?
    end
  end
  ['costan+alias@mit.edu', 'mba@harvard.edu'].each do |email|
    it "accepts valid e-mail: #{email}" do
      @user.email = email
      @user.save!
      assert @user.valid?
    end
  end
  it 'rejects non-.edu e-mail addresses' do
    @user.email = 'dvdjon@gmail.com'
    assert @user.invalid?
  end

  describe 'roles' do
    it 'destroys dependent records' do
      assert_not_empty staff.roles
      assert_not_empty dexter.role_requests

      staff.destroy
      dexter.destroy

      assert_empty staff.roles.reload
      assert_empty dexter.role_requests.reload
    end

    describe '#has_role?' do
      describe 'site-level roles' do
        it 'returns true if the user has the given role' do
          assert_equal true, admin.has_role?('admin')
        end

        it 'returns false if a course is specified for a site-level role' do
          assert_equal false, admin.has_role?('admin', courses(:main))
        end
      end

      describe 'course-level roles' do
        it 'returns true if the user has the role in the given course' do
          assert_equal true, staff.has_role?('staff', courses(:main))
          assert_equal false, staff.has_role?('staff', courses(:not_main))
        end

        it 'returns false if the course is omitted for a course-level role' do
          assert_equal false, staff.has_role?('staff')
        end
      end
    end

    describe '#admin?' do
      it 'returns true only for site admins' do
        assert_equal false, dexter.admin?
        assert_equal false, robot.admin?
        assert_equal false, grader.admin?
        assert_equal false, staff.admin?
        assert_equal true, admin.admin?
      end
    end

    describe '#robot?' do
      it 'returns true only for automated site users' do
        assert_equal false, dexter.robot?
        assert_equal true, robot.robot?
        assert_equal false, grader.robot?
        assert_equal false, staff.robot?
        assert_equal false, admin.robot?
      end
    end

    describe '.robot' do
      it 'returns the automated site user' do
        assert_equal robot, User.robot
      end
    end

    describe '#is_staff_in_course?' do
      it 'returns true if the given user staffs a course this user takes' do
        assert_equal true, staff.is_staff_in_course?(dexter)
        assert_equal false, users(:not_main_staff).is_staff_in_course?(dexter)
      end

      it 'returns true if the given user staffs a course this user grades' do
        assert_equal true, staff.is_staff_in_course?(grader)
        assert_equal false, users(:not_main_staff).is_staff_in_course?(grader)
      end

      it 'returns true if the given user staffs a course this user staffs' do
        assert_equal true, another_staff.is_staff_in_course?(staff)
        assert_equal false, users(:not_main_staff).is_staff_in_course?(staff)
      end

      it 'returns false if the given user is nil' do
        assert_equal false, dexter.is_staff_in_course?(nil)
      end
    end
  end

  describe 'site identity and class membership' do
    it 'destroys dependent records' do
      assert_not_nil dexter.profile
      assert_not_empty dexter.registrations

      dexter.destroy

      assert_nil Profile.find_by(user: users(:dexter))
      assert_empty dexter.registrations.reload
    end

    it 'requires a profile' do
      @user.profile = nil
      assert @user.invalid?
    end

    it 'saves the associated profile through the parent user' do
      new_name = @user.profile.name + ' Jr.'
      params = { profile_attributes: { name: new_name } }
      @user.update! params

      assert_equal new_name, @user.profile.name
      assert_equal 'MIT', @user.profile.university
    end

    describe 'by_name scope' do
      it 'sorts the users by name in alphabetical order' do
        golden = users(:solo, :deedee, :dexter, :mandark, :main_dropout)
        assert_equal golden, courses(:main).users.by_name
      end
    end

    describe '#name' do
      it 'returns the profile name' do
        assert_equal 'Dexter Boy Genius', dexter.name
      end
    end

    describe '#display_name_for' do
      it "returns 'You' if the user is also the viewer" do
        assert_equal 'You', dexter.display_name_for(dexter)
      end

      it "returns the user's name by default" do
        assert_equal 'Dexter Boy Genius', dexter.display_name_for
      end

      it "returns the user's name and email if :short format is specified" do
        assert_equal 'Dexter Boy Genius [genius+6006@mit.edu]',
                     dexter.display_name_for(staff, :long)
      end
    end

    describe '#can_read?' do
      it 'lets one view their own user information' do
        assert_equal true, dexter.can_read?(dexter)
      end

      describe 'student permissions' do
        it 'lets students view the user info of staff in their courses' do
          assert_equal true, staff.can_read?(dexter)
          assert_equal false, staff.can_read?(users(:not_main_dropout))
          assert_equal false, users(:not_main_staff).can_read?(dexter)
          assert_equal false, users(:not_main_grader).can_read?(dexter)
        end

        it 'lets students view the user info of their teammates' do
          assert_equal true, users(:deedee).can_read?(dexter)
          assert_equal false, users(:mandark).can_read?(dexter)
        end
      end

      it "lets anyone view a site admin's user information" do
        assert_equal true, admin.can_read?(dexter)
        assert_equal true, admin.can_read?(robot)
        assert_equal true, admin.can_read?(grader)
        assert_equal true, admin.can_read?(staff)
      end

      it "lets the admin view any user's information" do
        assert_equal true, dexter.can_read?(admin)
        assert_equal true, robot.can_read?(admin)
        assert_equal true, grader.can_read?(admin)
        assert_equal true, staff.can_read?(admin)
      end

      it 'lets graders view the user info of staff in their courses' do
        assert_equal true, staff.can_read?(grader)
        assert_equal false, dexter.can_read?(grader)
        assert_equal false, another_grader.can_read?(grader)
        assert_equal false, users(:not_main_staff).can_read?(grader)
        assert_equal false, users(:not_main_grader).can_read?(grader)
      end

      it 'lets staff view the user info of staff/students/graders in their
          courses' do
        assert_equal true, another_staff.can_read?(staff)
        assert_equal true, dexter.can_read?(staff)
        assert_equal true, grader.can_read?(staff)
        assert_equal false, users(:not_main_staff).can_read?(staff)
        assert_equal false, users(:not_main_dropout).can_read?(staff)
        assert_equal false, users(:not_main_grader).can_read?(staff)
      end
    end

    describe '#can_edit?' do
      it 'lets only the owner and site admins edit user information' do
        assert_equal true, dexter.can_edit?(dexter)
        assert_equal false, dexter.can_edit?(robot)
        assert_equal false, dexter.can_edit?(grader)
        assert_equal false, dexter.can_edit?(staff)
        assert_equal true, dexter.can_edit?(admin)
        assert_equal false, dexter.can_edit?(solo)
        assert_equal false, dexter.can_edit?(nil)
      end
    end

    describe '#registration_for' do
      it "returns the user's registration for the given course" do
        assert_equal registrations(:dexter),
            dexter.registration_for(courses(:main))
        assert_nil dexter.registration_for(nil)
      end

      it 'returns nil if the user is not registered for the given course' do
        assert_nil users(:not_main_dropout).registration_for(courses(:main))
        assert_nil staff.registration_for(courses(:main))
      end
    end

    describe '#recitation_section_for' do
      it "returns the user's recitation section for the given course" do
        assert_equal recitation_sections(:r01),
            dexter.recitation_section_for(courses(:main))
        assert_nil dexter.recitation_section_for(nil)
      end

      it 'returns nil if the user does not have a recitation in the given
          course' do
        assert_nil dexter.recitation_section_for(courses(:not_main))
      end
    end

    describe '#enrolled_in_course?' do
      it 'returns true of the user is registered for the course' do
        assert_equal true, dexter.enrolled_in_course?(courses(:main))
        assert_equal false, dexter.enrolled_in_course?(courses(:not_main))
        assert_equal false, dexter.enrolled_in_course?(nil)
      end
    end
  end

  describe 'homework submission feature' do
    let(:students) { courses(:main).students }

    it 'destroys/nullifies dependent records' do
      assert_not_empty dexter.submissions
      assert_not_empty dexter.extensions
      assert_not_empty staff.granted_extensions

      dexter.destroy
      staff.destroy

      assert_empty dexter.submissions.reload
      assert_empty dexter.extensions.reload
      staff.granted_extensions.reload.map(&:grantor_id).all? &:nil?
    end

    describe 'connected_submissions' do
      it 'should include submissions from co-team members' do
        golden = submissions(:dexter_ps1, :dexter_project, :dexter_project_v2,
            :dexter_assessment, :dexter_assessment_v2, :dexter_code,
            :dexter_code_v2)
        assert_equal golden.to_set, dexter.connected_submissions.to_set
      end

      it "should report user submissions if the user isn't in any teams" do
        assert_equal [submissions(:solo_ps1)], solo.connected_submissions
      end
    end

    describe '.without_extensions_for' do
      it 'filters for users without an extension for the given assignment' do
        assert_equal users(:solo, :mandark).to_set,
            students.without_extensions_for(assignments(:assessment)).to_set
        assert_equal users(:deedee, :solo, :mandark).to_set,
            students.without_extensions_for(assignments(:ps1)).to_set
      end
    end

    describe '#extension_for' do
      it "returns the user's extension, if any, for the given assignment" do
        assert_equal deadline_extensions(:assessment_dexter),
            dexter.extension_for(assignments(:assessment))
      end

      it 'returns nil if the user does not have an extension' do
        assert_nil assignments(:ps1).extensions.find_by(user: solo)
        assert_nil solo.extension_for(assignments(:ps1))
      end
    end
  end

  describe 'submission feedback and grading' do
    it 'destroys dependent records' do
      assert_not_empty dexter.direct_grades
      assert_not_empty dexter.direct_comments

      dexter.destroy

      assert_empty dexter.direct_grades.reload
      assert_empty dexter.direct_comments.reload
    end

    describe 'grades_for' do
      it 'should include grades on team assignments' do
        golden = grades(:awesome_ps1_p1, :awesome_ps2_p1, :awesome_project,
                        :dexter_assessment_quality, :dexter_assessment_overall)
        actual = dexter.grades_for courses(:main)
        assert_equal golden.to_set, actual.to_set
      end

      it 'takes the course argument into account' do
        assert_equal [], dexter.grades_for(courses(:not_main))
      end
    end

    describe '#comments_for' do
      it 'includes comments on both individual and team assignments' do
        golden = grade_comments(:dexter_assessment_overall, :dexter_ps1_p1)
        assert_equal golden.to_set, dexter.comments_for(courses(:main)).to_set
      end

      it 'includes comments made in the given course only' do
        assert_equal [], dexter.comments_for(courses(:not_main))
      end
    end
  end

  describe 'recitations' do
    it 'destroys dependent records' do
      assert_not_empty dexter.recitation_assignments

      dexter.destroy

      assert_empty dexter.recitation_assignments.reload
    end
  end

  describe 'teams' do
    it 'destroys dependent records' do
      assert_not_empty dexter.team_memberships

      dexter.destroy

      assert_empty dexter.team_memberships.reload
    end

    describe '#teams_for' do
      it 'returns the teams in the given course that include the user' do
        golden = teams(:awesome_pset, :awesome_project)
        assert_equal golden.to_set, dexter.teams_for(courses(:main)).to_set
      end
    end

    describe '#teammate_of?' do
      it 'returns true if the given user is on any team with this user' do
        assert_equal true, dexter.teammate_of?(users(:deedee))
        assert_equal false, dexter.teammate_of?(users(:mandark))
        assert_equal false, dexter.teammate_of?(nil)
      end
    end
  end

  describe 'feedback survey integration' do
    it 'destroys dependent records' do
      assert_not_empty dexter.survey_responses

      dexter.destroy

      assert_empty dexter.survey_responses.reload
    end
  end
end
