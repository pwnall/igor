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

  describe '#enrolled_in_course?' do
    it 'returns true of the user is registered for the course' do
      assert_equal true, dexter.enrolled_in_course?(courses(:main))
      assert_equal false, dexter.enrolled_in_course?(courses(:not_main))
      assert_equal false, dexter.enrolled_in_course?(nil)
    end
  end

  describe 'connected_submissions' do
    it 'should include submissions from co-team members' do
      skip 'resolve paperclip gems incompatibilities with edge rails'
      assert_equal [submissions(:admin_ps1), submissions(:inactive_project)].
          sort_by(&:id), dexter.connected_submissions.sort_by(&:id)
    end
    it "should report user submissions if the user isn't in any teams" do
      skip 'resolve paperclip gems incompatibilities with edge rails'
      assert_equal [submissions(:solo_ps1)], solo.connected_submissions
    end
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

  describe 'name' do
    it 'should report .edu e-mail if no profile is available' do
      assert_equal 'costan@mit.edu', admin.name
    end
    it 'should use name on profile if available' do
      assert_equal 'Dexter Boy Genius', dexter.name
    end
  end

  describe 'athena_id' do
    it 'should use e-mail prefix if no profile is available' do
      assert_equal 'costan', admin.athena_id
    end
    it 'should user profile info if available' do
      assert_equal 'genius', dexter.athena_id
    end
  end
end
