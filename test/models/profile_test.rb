require 'test_helper'

describe Profile do

  before do
    @profile = Profile.new athena_username: 'mitstudent', name: 'Tim Beaver',
        nickname: 'timster', year: 'G', university: 'MIT', department: 'EECS',
        user: User.new
  end

  it 'validates the setup profile' do
    assert @profile.valid?
  end

  it 'requires an athena username' do
    @profile.athena_username = nil
    assert @profile.invalid?
  end

  it 'rejects lengthy athena usernames' do
    @profile.athena_username = 'tim' * 11
    assert @profile.invalid?
  end

  it 'requires a name' do
    @profile.name = nil
    assert @profile.invalid?
  end

  it 'rejects lengthy names' do
    @profile.name = 'T' * 129
    assert @profile.invalid?
  end

  it 'requires a nickname' do
    @profile.nickname = nil
    assert @profile.invalid?
  end

  it 'reject lengthy nicknames' do
    @profile.nickname = 'tim' * 22
    assert @profile.invalid?
  end

  it 'requires a year' do
    @profile.year = nil
    assert @profile.invalid?
  end

  it 'rejects invalid years' do
    @profile.year = 'U'
    assert @profile.invalid?
  end

  it 'requires a university' do
    @profile.university = nil
    assert @profile.invalid?
  end

  it 'rejects lengthy university names' do
    @profile.university = 'MIT' * 22
    assert @profile.invalid?
  end

  it 'requires a department' do
    @profile.department = nil
    assert @profile.invalid?
  end

  it 'rejects lengthy department names' do
    @profile.department = 'cat' * 22
    assert @profile.invalid?
  end

  it 'requires a user' do
    @profile.user = nil
    assert @profile.invalid?
  end

  it 'forbids a user from having multiple profiles' do
    @profile.user = profiles(:dexter).user
    assert @profile.invalid?
  end

  describe '#can_edit?' do
    it 'allows a user to edit their own profile' do
      assert @profile.can_edit?(@profile.user)
    end

    it 'allows an admin to edit any profile' do
      assert @profile.can_edit?(users(:admin))
    end

    it 'forbids a non-admin to edit a profile other than their own' do
      assert !@profile.can_edit?(users(:dexter))
    end
  end
end
