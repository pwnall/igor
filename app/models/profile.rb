# == Schema Information
# Schema version: 20110429095601
#
# Table name: profiles
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)      not null
#  real_name         :string(128)     not null
#  nickname          :string(64)      not null
#  university        :string(64)      not null
#  department        :string(64)      not null
#  year              :string(4)       not null
#  athena_username   :string(32)      not null
#  about_me          :string(4096)    default(""), not null
#  allows_publishing :boolean(1)      default(TRUE), not null
#  phone_number      :string(64)
#  aim_name          :string(64)
#  jabber_name       :string(64)
#  created_at        :datetime
#  updated_at        :datetime
#

# User data, asides from credentials which are stored in the User model.
class Profile < ActiveRecord::Base 
  # The user's full legal name.
  validates :real_name, :length => 1..128, :presence => true
  
  # The way the user prefers to be called.
  validates :nickname, :length => 1..64, :presence => true
  
  # The user's school year.
  validates :year, :inclusion => { :in => %w(1 2 3 4 G) }, :presence => true

  # The user's school (e.g., "Massachusetts Institute of Technology").
  validates :university, :length => 1..64, :presence => true
  
  # The user's department (e.g., "Electrical Eng & Computer Sci").
  validates :department, :length => 1..64, :presence => true
  
  # The user's account.
  belongs_to :user, :inverse_of => :profile
  validates :user, :presence => true
  validates :user_id, :uniqueness => true
  
  # True if the user consents to having their work published on the Web.
  validates :allows_publishing, :inclusion => { :in => [true, false] }
  
  # The phone number the student will use to contact us.
  validates :phone_number, :length => { :in => 1..64, :allow_nil => true }
  
  # The AIM name the student will use to contact us.
  validates :aim_name, :length => { :in => 1..64, :allow_nil => true }

  # The Jabber name the student will use to contact us.
  validates :jabber_name, :length => { :in => 1..64, :allow_nil => true }
  
  # Self-description that the site admins can see.
  validates :about_me, :length => 0..(4.kilobytes)
  
  # The user's avatar.
  has_one :photo, :class_name => 'ProfilePhoto'
  
  def phone_number=(new_number)
    super(new_number.blank? ? nil : new_number)    
  end
  def aim_name=(new_name)
    super(new_name.blank? ? nil : new_name)    
  end
  def jabber_name=(new_name)
    super(new_name.blank? ? nil : new_name)    
  end

  # Returns true if the given user is allowed to edit this profile.
  def editable_by_user?(user)
    user and (user == self.user or user.admin?)
  end
end
