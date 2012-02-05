# Methods for rendering generic UI icons.
module IconsHelper
  # Show this icon to tell the user that his input is valid.
  def valid_icon_tag
    image_tag 'checkmark.png', :alt => 'Valid input', :class => 'ui-icon'
  end
  
  # Show this icon to tell the user that his input has some errors.
  def invalid_icon_tag
    image_tag 'error.png', :alt => 'Invalid input', :class => 'ui-icon'
  end
  
  # Show this icon on links to the next step in a multi-step process. 
  def next_step_icon_tag
    image_tag 'next.png', :alt => 'Next step', :class => 'ui-icon'
  end
  
  # Access levels / roles throughout the site.
  def role_icon_tag(role = :student)
    case role
    when :student
      image_tag 'student.png', :alt => 'Student', :class => 'ui-icon'
    when :staff
      image_tag 'staff.png', :alt => 'Course Staff', :class => 'ui-icon'
    when :team
      image_tag 'team.png', :alt => 'Team', :class => 'ui-icon'
    when :public
      image_tag 'public.png', :alt => 'Public', :class => 'ui-icon'
    else
      raise "Unknown role #{role}!"
    end
  end
  
  # The icon that communicates an assignment's state to the user.
  def assignment_state_icon_tag(state = :open)
    case state
    when :draft
      image_tag 'draft.png', :alt => 'Draft', :class => 'ui-icon'
    when :open
      image_tag 'running.png', :alt => 'Open', :class => 'ui-icon'
    when :grading
      image_tag 'waiting.png', :alt => 'Processing', :class => 'ui-icon'
    when :graded
      image_tag 'grades.png', :alt => 'Grades', :class => 'ui-icon'
    end
  end
end
