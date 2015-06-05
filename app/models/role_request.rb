# A request by a user to receive a privilege.
class RoleRequest < ActiveRecord::Base
  include RoleBase

  # Creates the Role referred to by this request.
  def approve
    Role.grant user, name, course
  end
end
