# Choose the 'assignments' or 'session' layout, depending on the current user.
module SidebarLayout
  extend ActiveSupport::Concern

  included do
    layout lambda { |controller|
      if controller.current_course.is_staff? controller.current_user
        'assignments'
      else
        'session'
      end
    }
  end
end
