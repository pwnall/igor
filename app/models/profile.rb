# == Schema Information
# Schema version: 20100203124712
#
# Table name: profiles
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)      not null
#  real_name             :string(128)     not null
#  nickname              :string(64)      not null
#  year                  :string(255)     not null
#  athena_username       :string(16)      not null
#  about_me              :string(4096)    default(""), not null
#  has_phone             :boolean(1)      default(TRUE), not null
#  phone_number          :string(64)
#  has_aim               :boolean(1)      not null
#  aim_name              :string(64)
#  has_jabber            :boolean(1)      not null
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
  belongs_to :recitation_section
  
  # True if the user consents to having their work published on the Web.
  validates_inclusion_of :allows_publishing, :in => [true, false]
  
  # True if the student expects to contact us via phone.
  validates_inclusion_of :has_phone, :in => [true, false]
  
  # The phone number the student will use to contact us.
  validates_length_of :phone_number, :in => 1..64, :allow_nil => true
  
  # True if the student wants to share their AIM with us.
  validates_inclusion_of :has_aim, :in => [true, false]
  
  # The AIM name the student will use to contact us.
  validates_length_of :aim_name, :in => 1..64, :allow_nil => true

  # True if the student wants to share their Jabber ID with us.
  validates_inclusion_of :has_jabber, :in => [true, false]

  # The Jabber name the student will use to contact us.
  validates_length_of :jabber_name, :in => 1..64, :allow_nil => true
  
  # Self-description that the site admins can see.
  validates_length_of :about_me, :in => 1..(4.kilobytes), :allow_nil => false
end
