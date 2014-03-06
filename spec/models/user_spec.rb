# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  exuid      :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#  admin      :boolean          default(FALSE), not null
#

require 'spec_helper'

describe User do
  fixtures :users, :credentials, :profiles, :grades, :submissions

  let(:dvdjohn) do
    User.new :email => 'dvdjohn@mit.edu', :password => 'awesome',
             :password_confirmation => 'awesome', :admin => true
  end
  let(:dexter) { users(:dexter) }
  let(:admin) { users(:admin) }
  let(:solo) { users(:solo) }
  let(:inactive) { users(:inactive) }

  it 'should accept valid user construction' do
    dvdjohn.should be_valid
  end

  ['costan@gmail.com', 'cos tan@gmail.com', 'costan@x@mit.edu', 'costan@mitZedu'].each do |email|
    it "should reject invalid e-mail #{email}" do
      dvdjohn.email = email
      dvdjohn.should_not be_valid
    end
  end
  ['costan+alias@mit.edu', 'mba@harvard.edu'].each do |email|
    it "should accept e-mail #{email}" do
      dvdjohn.email = email
      dvdjohn.save!
      dvdjohn.should be_valid
    end
  end
  it 'should reject non-.edu e-mail addresses' do
    dvdjohn.email = 'dvdjohn@gmail.com'
    dvdjohn.should_not be_valid
  end

  it 'should reject users without an admin flag' do
    dvdjohn.admin = nil
    dvdjohn.should_not be_valid
  end
  it 'should not mass-assign admin' do
    dvdjohn.admin.should == false
  end

  describe 'connected_submissions' do
    it 'should include submissions from co-team members' do
      dexter.connected_submissions.should =~ [submissions(:admin_ps1),
          submissions(:inactive_project)]
    end
    it "should report user submissions if the user isn't in any teams" do
      solo.connected_submissions.should =~ [submissions(:solo_ps1)]
    end
  end

  describe 'grades' do
    it 'should include grades on team assignments' do
      golden = [:awesome_ps1_p1, :awesome_project, :dexter_assessment].
          map { |i| grades(i) }
      dexter.grades.should =~ golden
    end
  end

  describe 'name' do
    it 'should report .edu e-mail if no profile is available' do
      admin.name.should == 'costan@mit.edu'
    end
    it 'should use name on profile if available' do
      dexter.name.should == 'Dexter Boy Genius'
    end
  end

  describe 'athena_id' do
    it 'should use e-mail prefix if no profile is available' do
      admin.athena_id.should === 'costan'
    end
    it 'should user profile info if available' do
      dexter.athena_id.should == 'genius'
    end
  end
end
