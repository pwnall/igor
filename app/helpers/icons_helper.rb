# Methods for rendering generic UI icons.
module IconsHelper
  # Show this icon to tell the user that his input is valid.
  def valid_icon_tag
    image_tag 'icons/checkmark.png', alt: 'Valid input', class: 'ui-icon'
  end
  
  # Show this icon to tell the user that his input has some errors.
  def invalid_icon_tag
    image_tag 'icons/error.png', alt: 'Invalid input', class: 'ui-icon'
  end
  
  # Show this icon on links to the next step in a multi-step process. 
  def next_step_icon_tag
    image_tag 'icons/next.png', alt: 'Next step', class: 'ui-icon'
  end
  
  # Show this icon on buttons that lead to creating data.
  def create_icon_tag
    image_tag 'icons/add.png', alt: 'Add New Item', class: 'ui-icon'
  end
  
  # Show this icon on buttons that delete some data (e.g. ActiveRecord.destroy).
  def destroy_icon_tag
    image_tag 'icons/destroy.png', alt: 'Remove', class: 'ui-icon'
  end
  
  # Access levels / roles throughout the site.
  def role_icon_tag(role = :student)
    case role
    when :student
      image_tag 'icons/student.png', alt: 'Student', class: 'ui-icon'
    when :staff
      image_tag 'icons/staff.png', alt: 'Course Staff', class: 'ui-icon'
    when :team
      image_tag 'icons/team.png', alt: 'Team', class: 'ui-icon'
    when :public
      image_tag 'icons/public.png', alt: 'Public', class: 'ui-icon'
    else
      raise "Unknown role #{role}!"
    end
  end
  
  # The icon that communicates an assignment's state to the user.
  def assignment_state_icon_tag(state = :open)
    case state
    when :draft
      image_tag 'icons/draft.png', alt: 'Under Construction', class: 'ui-icon'
    when :open
      image_tag 'icons/running.png', alt: 'Accepting Submissions',
                class: 'ui-icon'
    when :grading
      image_tag 'icons/waiting.png', alt: 'Grading in Progress',
                class: 'ui-icon'
    when :graded
      image_tag 'icons/grades.png', alt: 'Grades', class: 'ui-icon'
    end
  end
  
  # Show this icon on buttons for chronologically ordered lists of events.
  def feed_icon_tag
    image_tag 'icons/feed.png', alt: 'Change History', class: 'ui-icon'
  end
  
  # Show this icon next to submission-related functionality.
  def homework_icon_tag
    image_tag 'icons/homework.png', alt: 'Homework', class: 'ui-icon'
  end
  
  # Show this icon next to grading-related functionality.
  def grades_icon_tag
    image_tag 'icons/grades.png', alt: 'Grades', class: 'ui-icon'
  end
  
  # A bunch of unclassified tools.
  def toolbox_icon_tag
    image_tag 'icons/toolbox.png', alt: 'Toolbox', class: 'ui-icon'
  end
end
