# Methods for rendering generic UI icons.
module IconsHelper
  # Include dependencies since they aren't automatically included in tests.
  include AnalysesHelper  # For analysis_status_text.
  include ActionView::Helpers::TagHelper
  include FontAwesome::Rails::IconHelper

  # Tells the user that his input is valid.
  def valid_icon_tag
    fa_icon :check, title: 'Valid input'
  end

  # Tells the user that his input has some errors.
  def invalid_icon_tag
    fa_icon :'exclamation-triangle', title: 'Invalid input'
  end

  # Icon representing a truthy value.
  def true_icon_tag
    fa_icon :check, title: 'Yes'
  end

  # Icon representing a falsey value.
  def false_icon_tag
    fa_icon :times, title: 'No'
  end

  # Shown on links to the next step in a multi-step process.
  def build_icon_tag
    fa_icon :'chevron-circle-right', title: 'Next step'
  end

  # Shown on buttons that lead to creating data.
  def create_icon_tag
    fa_icon :plus, title: 'Create item'
  end

  # Shown on buttons that delete some data (e.g. ActiveRecord.destroy).
  def destroy_icon_tag
    fa_icon :trash, title: 'Remove'
  end

  # Shown on links that lead to an edit form.
  def edit_icon_tag
    fa_icon :pencil, title: 'Edit'
  end

  # Shown on links that fetch another page with data.
  def view_icon_tag
    fa_icon :eye, title: 'View'
  end

  # Shown on buttons that commit information to the database.
  def save_icon_tag
    fa_icon :'floppy-o', title: 'Save'
  end

  # Shown on buttons that show information based on a query.
  def search_icon_tag
    fa_icon :search, title: 'Search'
  end

  # Shown on buttons that reduce the information shown based on a filter.
  def filter_icon_tag
    fa_icon :filter, title: 'Filter'
  end

  # Show on buttons that lead to a list of records.
  def list_icon_tag
    fa_icon :list, title: 'View All'
  end

  # Show on buttons that promote auxiliary submissions.
  def promote_icon_tag(title: 'Select for grading')
    fa_icon :'angle-double-up', title: title
  end

  # Shown on buttons that generate a table out of existing data.
  def report_icon_tag
    fa_icon :'th-list', title: 'Generate report'
  end

  # Shown on links that lead to a help screen.
  def help_icon_tag
    fa_icon :info, title: 'Help'
  end

  # Shown on buttons that release some data to the public.
  def release_icon_tag
    fa_icon :unlock, title: 'Ship it!'
  end

  # Shown on buttons that pull back previously released data.
  def pull_icon_tag
    fa_icon :lock, title: 'Pull data'
  end

  # Shown on buttons that lead to a file download.
  def download_icon_tag
    fa_icon :'cloud-download', title: 'Download file'
  end

  # Shown on buttons that lead to a potentially lengthy file upload.
  def upload_icon_tag
    fa_icon :upload, title: 'Upload file'
  end

  # Shown on buttons that cause an expensive re-computation of cached state.
  def recompute_icon_tag
    fa_icon :repeat, title: 'Recompute'
  end

  # Access levels / roles throughout the site.
  def role_icon_tag(role = :student)
    case role
    when :student
      title = 'Student'
      icon_name = :'graduation-cap'
    when :staff
      title = 'Course Staff'
      icon_name = :university
    when :team
      title = 'Team'
      icon_name = :group
    when :public
      title = 'Public'
      icon_name = :globe
    when :admin
      title = 'Admin'
      icon_name = :key
    else
      raise "Unknown role #{role}!"
    end
    fa_icon icon_name, title: title
  end

  # The icon that communicates an assignment's state to the user.
  def assignment_state_icon_tag(state = :open)
    case state
    when :draft
      title = 'Under construction'
      icon_name = :lock
    when :open
      title = 'Accepting submissions'
      icon_name = :inbox
    when :grading
      title = 'Grading in progress'
      icon_name = :'pencil-square-o'
    when :graded
      title = 'Grades released'
      icon_name = :'check-square-o'
    else
      raise "Unknown state ${state}"
    end
    fa_icon icon_name, title: title, class: "#{state} fa-fw"
  end

  # Icon representing an analysis' status property.
  def analysis_status_icon_tag(analysis)
    title = analysis_status_text analysis
    status = analysis ? analysis.status : :analyzer_bug
    klass = 'fa-spin' if status == :queued

    icon_name = case status
    when :analyzer_bug
      :bug
    when :queued
      :spinner
    when :running
      :play
    when :limit_exceeded
      :'hourglass-end'
    when :crashed
      :bomb
    when :wrong
      :minus
    when :ok
      :check
    end
    fa_icon icon_name, title: title, class: klass
  end

  # Icon representing an ActionItem's progress state.
  def deadline_state_icon_tag(state)
    case state
    when :incomplete
      title = 'Task incomplete'
      icon_name = :'calendar-plus-o'
    when :rejected
      title = 'Rejected submission'
      icon_name = :'calendar-times-o'
    when :ok
      title = 'Task complete'
      icon_name = :'calendar-check-o'
    end
    fa_icon icon_name, title: title, class: 'fa-2x'
  end

  # Show this icon to represent a user.
  def user_icon_tag
    fa_icon :user
  end

  # Show this icon next to team-related functionality.
  def team_icon_tag
    fa_icon :group
  end

  # Show this icon next to forms that register the user for a class.
  def register_icon_tag
    fa_icon :'check-square-o'
  end

  # Show this icon next to role-requesting functionality.
  def role_request_icon_tag
    fa_icon :'user-plus'
  end

  # Show this icon next to forms that configure site features.
  def config_icon_tag
    fa_icon :sliders
  end

  # Shown on buttons for chronologically ordered lists of events.
  def feed_icon_tag
    fa_icon :feed
  end

  # Show this icon next to submission-related functionality.
  def homework_icon_tag
    fa_icon :book
  end

  # Show this icon next to submission-listing functionality.
  def submissions_icon_tag
    fa_icon :send
  end

  # Show this icon next to extension-granting functionality.
  def extensions_icon_tag
    fa_icon :'calendar-plus-o'
  end

  # Show this icon next to grading-related functionality.
  def grades_icon_tag
    fa_icon :'bar-chart'
  end

  # Show this icon to represent an ongoing process.
  def processing_icon_tag
    fa_icon :edit
  end

  # Show this icon next to recitation section-related functionality.
  def recitation_icon_tag
    fa_icon :'hand-o-up'
  end

  # Show this icon next to time-slot-related functionality.
  def time_slot_icon_tag
    fa_icon :'clock-o'
  end

  # Show this icon next to links that lead to displaying contact information.
  def contacts_icon_tag
    content_tag :span, class: 'stacked-icons' do
      fa_icon(:user) + fa_icon(:search, class: 'fa-inverse')
    end
  end

  # Show this icon next to links to aggregate information.
  def dashboard_icon_tag
    fa_icon :dashboard
  end

  # Show this icon next to survey / polling related functionality.
  def survey_icon_tag
    fa_icon :commenting
  end

  # A bunch of unrelated tools.
  def tools_icon_tag
    fa_icon :wrench
  end

  # Site debugging functionality.
  def debug_icon_tag
    fa_icon :bug
  end

  # Show this icon next to e-mail sending funtionality.
  def send_email_icon_tag
    content_tag :span, class: 'stacked-icons' do
      fa_icon(:envelope) + fa_icon(:'long-arrow-right', class: 'fa-inverse')
    end
  end

  # The list of courses available on the site.
  def course_list_icon_tag
    fa_icon :university
  end

  def email_resolvers_icon_tag
    content_tag :span, class: 'stacked-icons' do
      fa_icon(:envelope) + fa_icon(:search, class: 'fa-inverse')
    end
  end

  def background_jobs_tag
    fa_icon :'list-ol'
  end
end
