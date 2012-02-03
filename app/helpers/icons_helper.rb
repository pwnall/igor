# Methods for rendering generic UI icons.
module IconsHelper
  # Show this icon to tell the user that his input is valid.
  def valid_icon_tag
    image_tag 'checkmark.png', :alt => 'Valid input'
  end
  
  # Show this icon to tell the user that his input has some errors.
  def invalid_icon_tag
    image_tag 'error.png', :alt => 'Invalid input'
  end
  
  # Show this icon on links to the next step in a multi-step process. 
  def next_step_icon_tag
    image_tag 'next.png', :alt => 'Next step'
  end
  
  # Access levels / roles throughout the site.
  def role_icon_tag(role = :student)
    case role
    when :student
      image_tag 'student.png', :alt => 'Student'
    when :staff
      image_tag 'staff.png', :alt => 'Course Staff'
    when :team
      image_tag 'team.png', :alt => 'Team'
    when :public
      image_tag 'public.png', :alt => 'Public'
    else
      raise "Unknown role #{role}!"
    end
  end
end
