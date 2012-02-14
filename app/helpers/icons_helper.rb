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
    image_tag 'icons/add.png', alt: 'Create item', class: 'ui-icon'
  end
  
  # Show this icon on buttons that delete some data (e.g. ActiveRecord.destroy).
  def destroy_icon_tag
    image_tag 'icons/destroy.png', alt: 'Remove', class: 'ui-icon'
  end
  
  # Show this icon on links that lead to an edit form.
  def edit_icon_tag
    image_tag 'icons/edit.png', alt: 'Edit', class: 'ui-icon'
  end
  
  # Show this icon on buttons that commit information to the database.
  def save_icon_tag
    image_tag 'icons/save.png', alt: 'Save', class: 'ui-icon'
  end

  # Show this icon on buttons that lead to an edit form.
  def search_icon_tag
    image_tag 'icons/search.png', alt: 'Search', class: 'ui-icon'
  end

  # Show this icon on links that lead to printable material.
  def print_icon_tag
    image_tag 'icons/print.png', alt: 'Print', class: 'ui-icon'
  end

  # Show this icon on buttons that generate a table out of existing data.
  def report_icon_tag
    image_tag 'icons/report.png', alt: 'Print', class: 'ui-icon'
  end
  
  # Show this icon on buttons that release some data to the public.
  def ship_icon_tag
    image_tag 'icons/release.png', alt: 'Ship it!', class: 'ui-icon'
  end
  
  # Show this icon on buttons that pull back previously released data.
  def pull_icon_tag
    image_tag 'icons/revert.png', alt: 'Pull data', class: 'ui-icon'
  end

  # Show this icon on buttons that lead to a file download.
  def download_icon_tag
    image_tag 'icons/download.png', alt: 'Download file', class: 'ui-icon'
  end

  # Show this icon on buttons that lead to a potentially lengthy file upload.
  def upload_icon_tag
    image_tag 'icons/upload.png', alt: 'Upload file', class: 'ui-icon'
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
      image_tag 'icons/draft.png', alt: 'Under construction', class: 'ui-icon'
    when :open
      image_tag 'icons/running.png', alt: 'Accepting submissions',
                class: 'ui-icon'
    when :grading
      image_tag 'icons/waiting.png', alt: 'Grading in progress',
                class: 'ui-icon'
    when :graded
      image_tag 'icons/grades.png', alt: 'Grades', class: 'ui-icon'
    end
  end
  
  def deadline_state_icon_tag(state = :pending)
    case state
    when :pending
      image_tag 'icons/deadline.png', alt: 'Pending deadline', class: 'ui-icon'
    when :missed
      image_tag 'icons/deadline_missed.png', alt: 'Missed deadline',
                                             class: 'ui-icon'
    when :overdue
      image_tag 'icons/deadline_overdue.png', alt: 'Overdue', class: 'ui-icon'
    when :changing
      image_tag 'icons/waiting.png', alt: 'Processing', class: 'ui-icon'
    when :rejected
      image_tag 'icons/error.png', alt: 'Rejected submission', class: 'ui-icon'
    when :done
      image_tag 'icons/checkmark.png', alt: 'Done', class: 'ui-icon'
    end
  end
  
  # Show this icon next to forms that configure site features.
  def config_icon_tag
    image_tag 'icons/config.png', alt: 'Configuration', class: 'ui-icon'
  end

  # Show this icon on buttons for chronologically ordered lists of events.
  def feed_icon_tag
    image_tag 'icons/feed.png', alt: 'Change history', class: 'ui-icon'
  end
  
  # Show this icon next to submission-related functionality.
  def homework_icon_tag
    image_tag 'icons/homework.png', alt: 'Homework', class: 'ui-icon'
  end
  
  # Show this icon next to grading-related functionality.
  def grades_icon_tag
    image_tag 'icons/grades.png', alt: 'Grades', class: 'ui-icon'
  end
  
  # Show this icon next to links that lead to displaying contact information.
  def contacts_icon_tag
    image_tag 'icons/contacts.png', alt: 'Contacts', class: 'ui-icon'
  end

  # A bunch of unrelated tools.
  def tools_icon_tag
    image_tag 'icons/tools.png', alt: 'Toolbox', class: 'ui-icon'
  end
end
