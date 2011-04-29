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

# Credentials for a user in the system.
class User < ActiveRecord::Base
  # .edu e-mail address used to identify and endorse the user account.
  validates :email, :length => 1..64, :presence => true, :uniqueness => true,
      :format => { :with => /\A[A-Za-z0-9.+_-]+\@[A-Za-z0-9.\-]+\.edu\Z/,
                   :message => 'needs to be an .edu e-mail address' }
  
  # Random string preventing dictionary attacks on the password database.
  validates :password_salt, :length => 1..16, :presence => true
    
  # SHA-256 of (salt + password).
  validates :password_hash, :length => 1..64, :presence => true
  
  # Administrators are staff members.
  validates :admin, :inclusion => { :in => [true, false], :allow_nil => false }
  attr_protected :admin
  
  # Prevents logins from un-confirmed accounts.
  validates :active, :inclusion => { :in => [true, false], :allow_nil => false }
  attr_protected :active
  
  # Random strings used for password-less authentication.
  has_many :tokens, :dependent => :destroy, :inverse_of => :user
  
  # Personal information, e.g. full name and contact info.
  has_one :profile, :dependent => :destroy, :inverse_of => :user
  accepts_nested_attributes_for :profile

  # Class registration info, e.g. survey answers and credit / listener status.
  has_many :registrations, :dependent => :destroy, :inverse_of => :user
  accepts_nested_attributes_for :registrations
  
  # Files uploaded by the user to meet assignment deliverables.
  has_many :submissions, :dependent => :destroy, :inverse_of => :user
  
  # The user's answers to homework surveys.
  has_many :survey_answers, :dependent => :destroy, :inverse_of => :user

  # Grades assigned to the user, not to a team that the user belongs to.
  has_many :direct_grades, :class_name => 'Grade', :dependent => :destroy,
           :as => :subject

  # Backing model for the teams association.
  has_many :team_memberships, :dependent => :destroy, :inverse_of => :user
  
  # Teams that this user belongs to.
  has_many :teams, :through => :team_memberships, :inverse_of => :users

  # Virtual attribute: the user's password.
  attr_reader :password
  def password=(new_password)
    @password = new_password
    if new_password
      self.password_salt = [(0...12).map { |i| 1 + rand(255) }.pack('C*')].
                                     pack('m').strip
      self.password_hash = User.hash_password new_password, password_salt
    else
      self.password_salt = self.password_hash = nil
    end
  end
  
  # Virtual attribute: confirmation for the user's password.
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :allow_nil => true
  
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
    self.password = self.password_confirmation = nil
  end
  
  # The authenticated user or nil.
  def self.authenticate(email, password)
    user = User.where(:email => email).first
    (user && user.check_password(password)) ? user : nil
  end  
  
  # Submissions connected to this user.
  #
  # Returns the submissions authored by the user, as well as the submissions
  # authored by the user's teammates.
  def connected_submissions
    submissions = self.submissions.all
    teams.each { |team| submissions += team.submissions.all }
    submissions.uniq
  end
  
  # All the grades connected to a user.
  #
  # The returned set includes the user's direct grades, as well as grades
  # recorded for a team that the user is a part of.
  def grades
    direct_grades.includes(:metric => :assignment) +
        teams.includes(:grades => {:metric => :assignment}).
              map(&:grades).flatten
  end
  
  # The user's real name.
  #
  # Returns the email username if the user has not created a profile.
  def real_name
    (profile && profile.real_name) || email[0, email.index(?@)]
  end
  
  # The user's athena ID.
  #
  # Returns the email username if the user has not created a profile.
  def athena_id
    (profile && profile.athena_username) || email[0, email.index(?@)]
  end
  
  # The user's name, suitable to be displayed to the given user.
  def display_name_for(other_user = nil, identity_value = 'You')
    if self == other_user
      identity_value
    elsif profile and profile.real_name
      # TODO(costan): look at the other user's network, and if we're the only
      #               user with a given first name, return the first name
      profile.real_name
    elsif profile and profile.athena_username
      profile.athena_username
    else
      email[0, email.index(?@)]
    end      
  end

  # The user's registration for the main class on this site.
  def registration
    registrations.where(:course_id => Course.main.id).first
  end
  
  # Configure gravatars.
  include Gravtastic
  gravtastic :email, :secure => true, :rating => 'G', :filetype => 'png'
    
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
