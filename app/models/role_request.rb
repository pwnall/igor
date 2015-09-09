# == Schema Information
#
# Table name: role_requests
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  name       :string(8)        not null
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A request by a user to receive a privilege.
class RoleRequest < ActiveRecord::Base
  include RoleBase

  # Creates the Role referred to by this request.
  def approve
    Role.grant user, name, course
  end

  # True if the given user can remove this request.
  def can_destroy?(user)
    self.user == user || can_edit?(user)
  end
end
