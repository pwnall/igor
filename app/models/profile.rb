# == Schema Information
# Schema version: 20100503235401
#
# Table name: profiles
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)      not null
#  real_name             :string(128)     not null
#  nickname              :string(64)      not null
#  university            :string(64)      not null
#  department            :string(64)      not null
#  year                  :string(4)       not null
#  athena_username       :string(32)      not null
#  about_me              :string(4096)    default(""), not null
#  allows_publishing     :boolean(1)      default(TRUE), not null
#  phone_number          :string(64)
#  aim_name              :string(64)
#  jabber_name           :string(64)
#  recitation_section_id :integer(4)
#  created_at            :datetime
#  updated_at            :datetime
#

class Profile < ActiveRecord::Base 
  # The user's primary Athena account.
  validates_length_of :athena_username, :in => 1..32, :allow_nil => false
  
  # The user's legal name.
  validates_length_of :real_name, :in => 1..128, :allow_nil => false
  
  # The way the user prefers to be called.
  validates_length_of :nickname, :in => 1..64, :allow_nil => false 
  
  # The user's school year.
  validates_inclusion_of :year, :in => %w{ 1 2 3 4 G }, :allow_nil => false

  # The user's university (e.g., "Massachusetts Institute of Technology").
  validates_length_of :university, :in => 1..64, :allow_nil => false
  
  # The user's department (e.g., "Electrical Eng & Computer Sci").
  validates_length_of :department, :in => 1..64, :allow_nil => false
  
  # The user's account.
  belongs_to :user
  validates_uniqueness_of :user_id

  # The user's recitation section.
  #
  # This is only used if the user is a student and the course has recitations.
  # TODO(costan): this belongs in the course registration
  belongs_to :recitation_section
  
  # True if the user consents to having their work published on the Web.
  validates_inclusion_of :allows_publishing, :in => [true, false]
  
  # The phone number the student will use to contact us.
  validates_length_of :phone_number, :in => 1..64, :allow_nil => true
  
  # The AIM name the student will use to contact us.
  validates_length_of :aim_name, :in => 1..64, :allow_nil => true

  # The Jabber name the student will use to contact us.
  validates_length_of :jabber_name, :in => 1..64, :allow_nil => true
  
  # Self-description that the site admins can see.
  validates_length_of :about_me, :in => 0..(4.kilobytes), :allow_nil => false
  
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
