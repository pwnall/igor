module CourseFilters
  # Before action that sets the @course ivar from the URL segment.
  def set_current_course
    @current_course ||= Course.where(number: params[:course_id]).first!
  end

  attr_reader :current_course


  # (before-action) ensures that the session belongs to a course staff member
  def authenticated_as_course_editor
    authenticated_as_user
    return if performed?

    set_current_course
    bounce_user unless current_course.can_edit?(current_user)
  end

  # (before-action) ensures that the session belongs to a course staff member
  #   or grader
  def authenticated_as_course_grader
    authenticated_as_user
    return if performed?

    set_current_course
    bounce_user unless current_course.can_grade?(current_user)
  end
end
