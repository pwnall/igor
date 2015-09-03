require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :credentials, :profiles, :grades, :submissions

  let(:dvdjon) do
    User.new email: 'dvdjon@mit.edu', password: 'awesome',
      password_confirmation: 'awesome', profile_attributes: {
          name: 'Jon Johansen', nickname: 'dvdjon', university: 'MIT',
          department: 'EECS', year: 'G', athena_username: 'jon'
      }
  end
  let(:dexter) { users(:dexter) }
  let(:staff) { users(:main_staff) }
  let(:admin) { users(:admin) }
  let(:solo) { users(:solo) }
  let(:inactive) { users(:inactive) }

  it 'should accept valid user construction' do
    dvdjon.save!
    assert dvdjon.valid?
  end

  ['costan@gmail.com', 'cos tan@gmail.com', 'costan@x@mit.edu',
   'costan@mitZedu'].each do |email|
    it "should reject invalid e-mail #{email}" do
      dvdjon.email = email
      assert !dvdjon.valid?
    end
  end
  ['costan+alias@mit.edu', 'mba@harvard.edu'].each do |email|
    it "should accept e-mail #{email}" do
      dvdjon.email = email
      dvdjon.save!
      assert dvdjon.valid?
    end
  end
  it 'should reject non-.edu e-mail addresses' do
    dvdjon.email = 'dvdjon@gmail.com'
    assert !dvdjon.valid?
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
  end

  describe 'site identity and class membership' do
    it 'destroys dependent records' do
      assert_not_nil dexter.profile
      assert_not_empty dexter.registrations

      dexter.destroy

      assert_nil Profile.find_by(user: users(:dexter))
      assert_empty dexter.registrations.reload
    end

    describe 'by_name scope' do
      it 'sorts the users by name in alphabetical order' do
        golden = users(:solo, :deedee, :dexter, :dropout)
        assert_equal golden, courses(:main).users.by_name
      end
    end

    describe '#name' do
      it 'should report .edu e-mail if no profile is available' do
        assert_equal 'costan@mit.edu', admin.name
      end
      it 'should use name on profile if available' do
        assert_equal 'Dexter Boy Genius', dexter.name
      end
    end

    describe '#athena_id' do
      it 'should use e-mail prefix if no profile is available' do
        assert_equal 'costan', admin.athena_id
      end
      it 'should user profile info if available' do
        assert_equal 'genius', dexter.athena_id
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
        golden = submissions(:dexter_assessment, :dexter_code, :dexter_code_v2,
                             :admin_ps1, :inactive_project)
        assert_equal golden.to_set, dexter.connected_submissions.to_set
      end

      it "should report user submissions if the user isn't in any teams" do
        assert_equal [submissions(:solo_ps1)], solo.connected_submissions
      end
    end

    describe '.without_extensions_for' do
      it 'filters for users without an extension for the given assignment' do
        assert_equal [users(:solo)].to_set,
            students.without_extensions_for(assignments(:assessment)).to_set
        assert_equal users(:deedee, :dexter, :solo).to_set,
            students.without_extensions_for(assignments(:ps1)).to_set
      end
    end

    describe '#extension_for' do
      it "returns the user's extension, if any, for the given assignment" do
        assert_equal deadline_extensions(:assessment_dexter),
            dexter.extension_for(assignments(:assessment))
      end

      it 'returns nil if the user does not have an extension' do
        assert_nil assignments(:ps1).extensions.find_by user: dexter
        assert_nil dexter.extension_for(assignments(:ps1))
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
        golden = grades(:awesome_ps1_p1, :awesome_project,
                        :dexter_assessment_overall)
        assert_equal golden.to_set, dexter.grades_for(courses(:main)).to_set
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
  end

  describe 'feedback survey integration' do
    it 'destroys dependent records' do
      assert_not_empty dexter.survey_responses

      dexter.destroy

      assert_empty dexter.survey_responses.reload
    end
  end
end
