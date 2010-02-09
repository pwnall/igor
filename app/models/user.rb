# == Schema Information
# Schema version: 20100208065707
#
# Table name: users
#
#  id            :integer(4)      not null, primary key
#  name          :string(64)      not null
#  password_salt :string(16)      not null
#  password_hash :string(64)      not null
#  email         :string(64)      not null
#  active        :boolean(1)      not null
#  admin         :boolean(1)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

class User < ActiveRecord::Base
  has_many :tokens, :dependent => :destroy
  has_one :student_info, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_many :grades, :dependent => :destroy
  has_many :submissions, :dependent => :destroy
  has_many :notice_statuses, :dependent => :destroy
  has_many :notices, :through => :notice_statuses
  has_many :team_memberships, :dependent => :destroy
  has_many :teams, :through => :team_memberships

  attr_protected :admin, :active
  
  # The user name.
  validates_length_of :name, :in => 2..64, :allow_nil => false
  validates_format_of :name, :with => /^\w+$/, :message => 'can only contain letters, numbers, and _'  
  validates_uniqueness_of :name  
  
  # Random string preventing dictionary attacks on the password database.
  validates_length_of :password_salt, :in => 1..16, :allow_nil => false
    
  # SHA-256 of (salt + password).
  validates_length_of :password_hash, :in => 1..64, :allow_nil => false
  
  # @mit.edu e-mail address used to endorse the user account.
  validates_format_of :email, :with => /^[A-Za-z0-9.+_]+@mit.edu$/,
                      :message => 'needs to be an @mit.edu e-mail address',
                      :allow_nil => false
  validates_length_of :email, :in => 1..64
  validates_uniqueness_of :email
  
  # Administrators are staff members.  
  validates_inclusion_of :admin, :in => [true, false]
  
  # Prevents logins from un-confirmed accounts.
  validates_inclusion_of :active, :in => [true, false]
  
  # Virtual attribute: the user's password.
  validates_presence_of :password, :on => :create
  attr_reader :password
  attr_accessor :password_confirmation
  def password=(new_password)
    @password = new_password
    self.password_salt = (0...16).map { |i| 1 + rand(255) }.pack('C*')
    self.password_hash = User.hash_password new_password, password_salt
  end
  
  # Virtual attribute: confirmation for the user's password.
  validates_confirmation_of :password
  
  # Compares the given password against the user's stored password.
  #
  # Returns +true+ for a match, +false+ otherwise.
  def check_password(passwd)
    password_hash == User.hash_password(passwd, password_salt)
  end
  
  # Computes a password hash from a raw password and a salt.
  def self.hash_password(password, salt)
    Digest::SHA2.hexdigest(password + salt)
  end
  
  # Resets the virtual password attributes.
  def reset_password
    @password = @password_confirmation = nil
  end
  
  # The authenticated user or nil.
  def self.authenticate(user_name, password)
    @user = User.find :first, :conditions => {:name => user_name }    
    (@user && @user.check_password(password)) ? @user : nil
  end  
  
  # The user's real name.
  #
  # Returns the email username if the user has not created a profile.
  def real_name
    profile ? profile.real_name : email[0, email.index(?@)]
  end
  
  # The user's athena ID.
  #
  # Returns the email username if the user has not created a profile.
  def athena_id
    profile ? profile.athena_username : email[0, email.index(?@)]
  end
  
  # TODO(costan): move query processing in another class
  
  # Parses a free-form user search query.
  #
  # Queries have the form "something [name <email>]", and any of the components
  # may be missing.
  #
  # Returns a hash with the keys +:string+, +:name+ and +:email+. Each key's
  # value can be nil or a string.
  def self.parse_freeform_query(query)
    query = query.strip
    
    name_match = /^([^\[]*)\[(.+)\]$/.match query
    if name_match
      query_string, query = name_match[1], name_match[2]
    else
      query_string = nil
    end
    
    email_match = /^([^\<]*)\<(.+)\>$/.match query
    if email_match
      name, email = email_match[1], email_match[2]
    else
      name = query
      email = nil
    end
    
    [query_string, name, email].each { |piece| piece.strip! unless piece.nil? }
    query_string = nil if query_string and query_string.empty?
    name = nil if name and name.empty?
    email = nil if email and email.empty?
    
    query_string, name = name, nil if query_string.nil?
    { :string => query_string, :name => name, :email => email }
  end
  
  # 
  def self.score_query_part(needle, haystack, full_match, start_match,
                            end_match, inner_match)
    return 0 if needle.nil? or needle.empty?
    return full_match if needle == haystack
    return start_match if haystack.index(needle) == 0
    if haystack.rindex(needle) == haystack.length - needle.length
      return end_match
    end
    return inner_match if haystack.index needle
    0
  end
  
  # The score of this user against a user search query.
  def query_score(query)
    score = 0
    query = User.parse_freeform_query query
    
    # Username matching: 10 points.
    score += User.score_query_part query[:string], name,
                                   10, 5, 3, 2
      
    # Real name matching: 4 points.               
    score += User.score_query_part query[:name], real_name,
                                   4, 2, 1, 0.2
    score += User.score_query_part query[:string], real_name,
                                   2, 1, 0.5, 0.1

    # Email matching: 6 points.
    score += User.score_query_part query[:email], "#{athena_id}@mit.edu",
                                   6, 3, 1.5, 0.3
    score += User.score_query_part query[:string], "#{athena_id}@mit.edu",
                                   2, 1, 0.5, 0.1

    score / 20.0
  end

  def self.find_all_by_query!(query)
    query.gsub!(/ \[.*/, '')
    sql_query = '%' + query.strip + '%'
    matching_profiles = Profile.find(:all, :conditions => ['(real_name LIKE ?) OR (athena_username LIKE ?)', sql_query, sql_query], :include => :user)
    unscored_users = User.find(:all, :conditions => ['(name LIKE ?) OR (email LIKE ?)', sql_query, sql_query], :include => :profile) | matching_profiles.map { |i| i.user }
    unscored_users.map { |u| [u.query_score(query), u] }.sort_by { |v| [-v[0], v[1].name] }[0, 10].map(&:last)
  end
  
  def self.find_first_by_query!(query)
    find_all_by_query!(query).first    
  end
end
