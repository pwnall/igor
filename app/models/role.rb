# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  name       :string(8)        not null
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A privilege granted to an user.
class Role < ApplicationRecord
  include RoleBase

  before_destroy :preserve_site_bot
  before_destroy :preserve_one_site_admin

  # The auto-grading feature relies on a bot account to post grades.
  def preserve_site_bot
    throw :abort if name == 'bot'
  end
  private :preserve_site_bot

  # There is no way to create an admin from an admin-less state through the UI.
  def preserve_one_site_admin
    throw :abort if (name == 'admin') && (Role.where(name: 'admin').count == 1)
  end
  private :preserve_one_site_admin

  # Checks if a user has a privilege.
  def self.has_entry?(user, role_name, course = nil)
    self.where(user: user, name: role_name, course: course).count > 0
  end

  # Ensures that a user has a privilege.
  #
  # This creates a new Role if one doesn't already exist.
  def self.grant(user, role_name, course = nil)
    self.where(user: user, name: role_name, course: course).first_or_create!
  end

  # Ensures that a does not have a privilege.
  #
  # This deletes a Role if necessary.
  def self.revoke(user, role_name, course = nil)
    course_id = course.nil? ? nil : course.id
    self.where(user_id: user.id, name: role_name, course_id: course_id).
         destroy_all
  end

  # True if the given user can revoke this role.
  def can_destroy?(user)
    self.user == user || can_edit?(user)
  end
end
