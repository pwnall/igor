# A request by a user to receive a privilege.
class RoleRequest < RoleBase
  # Needed because we're not using STI.
  self.table_name = 'role_requests'

  # Creates the Role referred to by this request.
  def approve
    Role.grant user, name, course
  end
end
