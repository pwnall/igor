# Choose the 'assignments' or 'session' layout, depending on the current user.
module SidebarLayout
  extend ActiveSupport::Concern

  included do
    layout lambda {
      if current_course.is_staff?(current_user) || current_user.admin?
        'assignments'
      else
        'session'
      end
    }
  end
end
