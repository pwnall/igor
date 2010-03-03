require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new :name => 'dvdjohn', :password => 'awesome',
                     :password_confirmation => 'awesome',
                     :email => 'dvdjohn@mit.edu',
                     :active => true, :admin => true                     
  end
  
  def test_setup
    assert @user.valid?
  end
  
  def test_name_presence
    @user.name = nil
    assert !@user.valid?
  end
  
  def test_name_length
    @user.name = 'a'
    assert !@user.valid?, 'Overly short user name'
    @user.name = 'abcde' * 13
    assert !@user.valid?, 'Overly long user name'
  end
  
  def test_name_format
    ['pwn$', 'l@@k', 'awe some'].each do |name|
      @user.name = name
      assert !@user.valid?, "Bad name format - #{name}"
    end
  end
  
  def test_name_uniqueness
    @user.name = users(:admin).name
    assert !@user.valid?
  end
  
  def test_password_salt_presence
    @user.password_salt = nil
    assert !@user.valid?
  end
  
  def test_password_salt_length
    @user.password_salt = '12345' * 4
    assert !@user.valid?, 'Long salt'
    @user.password_salt = ''
    assert !@user.valid?, 'Empty salt'
  end
  
  def test_password_hash_presence
    @user.password_hash = nil
    assert !@user.valid?
  end
  
  def test_password_hash_length
    @user.password_hash = '12345' * 13
    assert !@user.valid?, 'Long hash'
    @user.password_hash = ''
    assert !@user.valid?, 'Empty hash'
  end
  
  def test_email_presence
    @user.email = nil
    assert !@user.valid?
  end
  
  def test_email_length
    @user.email = 'abcde' * 12 + '@mit.edu'
    assert !@user.valid?, 'Overly long user name'
  end
  
  def test_email_format
    ['costan@gmail.com', 'cos tan@gmail.com', 'costan@x@mit.edu'].each do |name|
      @user.name = name
      assert !@user.valid?, "Bad email format - #{name}"
    end    
  end
  
  def test_email_uniqueness
    @user.email = users(:admin).email
    assert !@user.valid?
  end
  
  def test_admin_presence
    @user.admin = nil
    assert !@user.valid?
  end
  
  def test_admin_mass_assign
    assert_equal false, @user.admin, 'admin got mass-assigned'
  end
  
  def test_active_presence
    @user.active = nil
    assert !@user.valid?
  end
  
  def test_active_mass_assign
    assert_equal false, @user.active, 'active got be mass-assigned'
  end
  
  def test_password_presence
    @user.reset_password
    assert !@user.valid?
  end
  
  def test_password_confirmation
    @user.password_confirmation = 'not awesome'
    assert !@user.valid?
  end
  
  def test_check_password
    assert_equal true, @user.check_password('awesome')
    assert_equal false, @user.check_password('not awesome'), 'Bogus password'
    assert_equal false, @user.check_password('password'),
                 "Another user's password" 
  end
  
  def test_authenticate
    assert_equal users(:admin), User.authenticate('admin', 'password')
    assert_equal nil, User.authenticate('admin', 'pa55w0rd'),
                 "Dexter's password on admin's account"
    assert_equal users(:dexter), User.authenticate('dexter', 'pa55w0rd')
    assert_equal nil, User.authenticate('dexter', 'password'),
                 "Admin's password on dexter's account"
    assert_equal nil, User.authenticate('dexter', 'awesome'), 'Bogus password'
  end
  
  test "connected_submissions for team user" do
    assert_equal Set.new([submissions(:admin_ps1),
                         submissions(:inactive_project)]),
                 Set.new(users(:dexter).connected_submissions)                 
  end
  
  test "connected_submissions for user with no teams" do
    assert_equal Set.new([submissions(:solo_ps1)]),
                 Set.new(users(:solo).connected_submissions)    
  end
  
  def test_real_name
    assert_equal 'costan', users(:admin).real_name
    assert_equal 'Dexter Boy Genius', users(:dexter).real_name    
  end
  
  def test_athena_id
    assert_equal 'costan', users(:admin).athena_id
    assert_equal 'genius', users(:dexter).athena_id
  end
  
  def test_parse_freeform_query
    [
      ['q [me <mine>]', {:string => 'q', :name => 'me', :email => 'mine'}],
      ['me', {:string => 'me', :name => nil, :email => nil}],
      ['[me]', {:string => 'me', :name => nil, :email => nil}],
      ['[me <mine>]', {:string => 'me', :name => nil, :email => 'mine'}],
      ['q [me <m[n]>]', {:string => 'q', :name => 'me', :email => 'm[n]'}],
      ['<mine>', {:string => nil, :name => nil, :email => 'mine'}],
      [' ', {:string => nil, :name => nil, :email => nil}]
    ].each do |query_test|
      assert_equal query_test.last, User.parse_freeform_query(query_test.first),
                   "Query #{query_test.first}"
    end
  end
  
  def test_score_query_part
    [
      ['awe', 'awe', 1],
      ['awe', 'awesome', 0.5],
      ['some', 'awesome', 0.3],
      ['so', 'awesome', 0.2],
      ['none', 'awesome', 0],
      ['', 'awesome', 0],
      [nil, 'awesome', 0]
    ].each do |score_test|
      assert_equal score_test[2],
                   User.score_query_part(score_test[0], score_test[1],
                                         1, 0.5, 0.3, 0.2),
                   "Query '#{score_test[0]}' on '#{score_test[1]}'"
    end
  end
  
  def test_query_score
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
    ].each do |query_test|
      assert_equal query_test[1], users(:admin).query_score(query_test.first),
                   "Query '#{query_test.first}' against admin"
      assert_equal query_test[2], users(:dexter).query_score(query_test.first),
                   "Query '#{query_test.first}' against dexter"
    end
    
    # TODO(costan): better score testing
  end
  
  def test_find_all_by_query
    assert_equal [users(:admin), users(:dexter), users(:inactive),
                  users(:solo)],
                 User.find_all_by_query!('i')
  end
  
  def test_find_first_by_query
    assert_equal users(:dexter), User.find_first_by_query!('dex')
  end
end
