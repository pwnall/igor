module MenuHelper
  # The type of menu to be shown for a user.
  #
  # @param [User] user the user who will see the menu
  # @param [
  # @return [String] the menu type; can be "student", "admin", "staff",
  #     "grader" or "guided" (for users who don't have a status yet)
  def menu_type(user, course)
    if course.nil?
      role = Role.where(user_id: current_user.id, course_id: nil).first
    else
      return 'student' if user.registrations.where(course_id: course.id).first

      role = Role.where(user_id: current_user.id, course_id: [nil, course.id]).
                  first
    end

    return role.name if role
    'guided'
  end
end
