require 'set'

# A privilege granted to an user.
class Role < ActiveRecord::Base
  include RoleBase

  # Checks if a user has a privilege.
  def self.has_entry?(user, role_name, course = nil)
    course_id = course.nil? ? nil : course.id
    self.where(user_id: user.id, name: role_name, course_id: course_id).
         count > 0
  end

  # Ensures that a user has a privilege.
  #
  # This creates a new Role if one doesn't already exist.
  def self.grant(user, role_name, course = nil)
    course_id = course.nil? ? nil : course.id
    self.find_or_create_by! user_id: user.id, name: role_name,
                            course_id: course_id
  end

  # Ensures that a does not have a privilege.
  #
  # This deletes a Role if necessary.
  def self.revoke(user, role_name, course = nil)
    course_id = course.nil? ? nil : course.id
    self.where(user_id: user.id, name: role_name, course_id: course_id).
         destroy_all
  end
end
