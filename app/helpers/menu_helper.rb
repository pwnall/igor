module MenuHelper
  # The type of menu to be shown for a user.
  #
  # @param [User] user the user who will see the menu
  # @param [Course] course the current course; nil, if no course selected
  # @return [String] the name of the partial view that accommodates the given
  #     user's most permissive role
  def menu_type(user, course)
    return 'menu/for_admin' if user.admin?
    if course
      if course.is_staff? user
        'menu/for_staff'
      elsif course.is_grader? user
        'menu/for_grader'
      elsif course.is_student? user
        'menu/for_student'
      else
        'menu/for_guided'  # for users who haven't registered for the course yet
      end
    else
      'menu/for_guided'  # for pages that aren't tied to a specific course
    end
  end
end
