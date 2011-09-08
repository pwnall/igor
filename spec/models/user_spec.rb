# == Schema Information
# Schema version: 20110429122654
#
# Table name: users
#
#  id            :integer(4)      not null, primary key
#  password_salt :string(16)      not null
#  password_hash :string(64)      not null
#  email         :string(64)      not null
#  active        :boolean(1)      not null
#  admin         :boolean(1)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe User do
  fixtures :users, :grades, :submissions
  
  let(:dvdjohn) do
    @dvdjohn = User.new :email => 'dvdjohn@mit.edu', :password => 'awesome',
             :password_confirmation => 'awesome', 
             :active => true, :admin => true
  end
  let(:dexter) { users(:dexter) }
  let(:admin) { users(:admin) }
  let(:solo) { users(:solo) }
  
  it 'should accept valid user construction' do
    dvdjohn.should be_valid
  end
  
  it 'should reject users without password salts' do
    dvdjohn.password_salt = nil
    dvdjohn.should_not be_valid
  end
  it 'should reject overly long password salts' do
    dvdjohn.password_salt = '12345' * 4
    dvdjohn.should_not be_valid
  end
  it 'should reject empty password salts' do
    dvdjohn.password_salt = ''
    dvdjohn.should_not be_valid
  end
  it 'should reject users without password hashes' do
    dvdjohn.password_hash = nil
    dvdjohn.should_not be_valid
  end
  
  it 'should reject overly long password hashes' do
    dvdjohn.password_hash = '12345' * 13
    dvdjohn.should_not be_valid
  end
  it 'should reject empty password hashes' do
    dvdjohn.password_hash = ''
    dvdjohn.should_not be_valid
  end
  
  it 'should reject users without e-mail addresses' do
    dvdjohn.email = nil
    dvdjohn.should_not be_valid
  end
  it 'should reject overly long e-mail addresses' do
    dvdjohn.email = 'abcde' * 12 + '@mit.edu'
    dvdjohn.should_not be_valid
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
  it 'should reject duplicate e-mail addresses' do
    dvdjohn.email = users(:admin).email
    dvdjohn.should_not be_valid
  end
  
  it 'should reject users without an admin flag' do
    dvdjohn.admin = nil
    dvdjohn.should_not be_valid
  end  
  it 'should not mass-assign admin' do
    dvdjohn.admin.should == false
  end
  
  it 'should reject users without an active flag' do
    dvdjohn.active = nil
    dvdjohn.should_not be_valid
  end
  it 'should not mass-asign active' do
    dvdjohn.active.should == false
  end
  
  it 'should check for password confirmation' do
    dvdjohn.password_confirmation = 'not awesome'
    dvdjohn.should_not be_valid    
  end
  
  describe 'reset_password' do
    it 'should blank the password fields' do
      dvdjohn.reset_password
      dvdjohn.should_not be_valid
      dvdjohn.password_salt.should be_nil
      dvdjohn.password_hash.should be_nil
    end
  end
  
  describe 'check_password' do
    it 'should work for the right password' do
      dvdjohn.check_password('awesome').should be_true
    end
    it 'should reject bogus password' do
      dvdjohn.check_password('not awesome').should be_false
    end
    it "should reject another user's password" do
      dvdjohn.check_password('password').should be_false
    end
  end
  
  describe 'authenticate' do
    it 'should work with good credentials' do
      User.authenticate('costan@mit.edu', 'password').should == admin
      User.authenticate('genius+6006@mit.edu', 'pa55w0rd').should == dexter
    end
    it "should reject dexter's password on admin's account" do
      User.authenticate('costan@mit.edu', 'pa55w0rd').should be_nil
    end
    it 'should reject bogus passwords' do
      User.authenticate('genius+6006@mit.edu', 'awesome').should be_nil
    end
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

  describe 'parse_freeform_query' do
    [
      ['q [me <mine>]', {:string => 'q', :name => 'me', :email => 'mine'}],
      ['me', {:string => 'me', :name => nil, :email => nil}],
      ['[me]', {:string => 'me', :name => nil, :email => nil}],
      ['[me <mine>]', {:string => 'me', :name => nil, :email => 'mine'}],
      ['q [me <m[n]>]', {:string => 'q', :name => 'me', :email => 'm[n]'}],
      ['<mine>', {:string => nil, :name => nil, :email => 'mine'}],
      [' ', {:string => nil, :name => nil, :email => nil}]
    ].each do |query_case|
      it "should work for #{query_case.first}" do
        User.parse_freeform_query(query_case.first).should == query_case.last
      end
    end
  end

  describe 'score_query_part' do
    [
      ['awe', 'awe', 1],
      ['awe', 'awesome', 0.5],
      ['some', 'awesome', 0.3],
      ['so', 'awesome', 0.2],
      ['none', 'awesome', 0],
      ['', 'awesome', 0],
      [nil, 'awesome', 0]
    ].each do |score_test|
      it "should handle (#{score_test[0]}, #{score_test[1]})" do
        User.score_query_part(score_test[0], score_test[1], 1, 0.5, 0.3, 0.2).
            should == score_test[2]
      end
    end
  end

  describe 'query_score' do
    [
      ['admin', 0.5, 0], ['dexter', 0, 0.5],
      ['costan@mit.edu', 0.1, 0],
      ['<genius@mit.edu>', 0, 0.3],
      ['genius+6006@mit.edu', 0, 0],  # E-mail used to sign up, not in profile.
      ['@mit.edu', 0.025, 0.025],
      ['costan', 0.15, 0],
      ['admin [Dexter Boy Genius]', 0.5, 0.2],
      ['admin [Dexter Boy Genius <genius@mit.edu>]', 0.5, 0.5],
      ['', 0, 0],
    ].each do |query_case|
      it "should work for #{query_case.first} against admin" do
        admin.query_score(query_case.first).should == query_case[1]
      end
      it "should work for #{query_case.first} against dexter" do
        dexter.query_score(query_case.first).should == query_case[2]
      end
    end
    
    # TODO(costan): better score testing
  end

  describe 'find_all_by_query' do
    it 'should rank all users for i' do
      User.find_all_by_query!('i').should == [users(:admin), users(:dexter),
                                              users(:solo), users(:inactive)]
    end
  end
  
  describe 'find_first_by_query' do
    it 'should work' do
      User.find_first_by_query!('dex').should == dexter
    end
  end
end
