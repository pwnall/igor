# == Schema Information
#
# Table name: profiles
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  name            :string(128)      not null
#  nickname        :string(64)       not null
#  university      :string(64)       not null
#  department      :string(64)       not null
#  year            :string(4)        not null
#  athena_username :string(32)       not null
#  about_me        :string(4096)     default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#

# User data, asides from credentials which are stored in the User model.
class Profile < ActiveRecord::Base
  # The user's Kerberos account on MIT's Athena system.
  validates :athena_username, length: 1..32, presence: true
  attr_accessible :athena_username

  # The user's full legal name.
  validates :name, length: 1..128, presence: true
  attr_accessible :name

  # The way the user prefers to be called.
  validates :nickname, length: 1..64, presence: true
  attr_accessible :nickname

  # The user's school year.
  validates :year, inclusion: { in: %w(1 2 3 4 G) }, presence: true
  attr_accessible :year

  # The user's school (e.g., "Massachusetts Institute of Technology").
  validates :university, length: 1..64, presence: true
  attr_accessible :university

  # The user's department (e.g., "Electrical Eng & Computer Sci").
  validates :department, length: 1..64, presence: true
  attr_accessible :department

  # The user's account.
  belongs_to :user, inverse_of: :profile
  validates :user, presence: true
  validates :user_id, uniqueness: true

  # Self-description that the site admins can see.
  validates :about_me, length: 0..(4.kilobytes)
  attr_accessible :about_me

  # The user's avatar.
  has_one :photo, class_name: 'ProfilePhoto', inverse_of: :profile

  # Returns true if the given user is allowed to edit this profile.
  def can_edit?(user)
    self.user.can_edit? user
  end
end
