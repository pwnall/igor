# Common functionality in Role and RoleRequest.
class RoleBase < ActiveRecord::Base
  # Disable STI for children.
  self.abstract_class = true

  # The user who requests/receives the privilege.
  belongs_to :user
  validates :user, presence: true

  # The course where the privilege applies.
  #
  # Some roles (e.g. "bot") apply site-wise. Others (e.g. "grader") are scoped
  # to a single course.
  belongs_to :course
  validates :user, presence: { allow_nil: true }

  # Maps roles to whether they're course-specific (true) or site-wide (false).
  ROLES = {
    'bot' => false,    # This user is a robot.
    'admin' => false,  # Site-wide administrator.
    'staff' => true,   # Course administrator.
    'grader' => true,  # Can enter grades for a course.
  }.freeze

  # The type of privilege.
  validates :name, presence: true, length: 1..8,
      inclusion: { in: RoleBase::ROLES },
      uniqueness: { scope: [:user_id, :course_id] }
  validate :course_matches_role
  # Ensures that only course-specific roles have the course field set.
  def course_matches_role
    is_course_specific = RoleBase::ROLES[name]
    return if is_course_specific.nil?  # The inclusion validation catches this.

    if is_course_specific
      unless course
        errors.add :course, "Course-specific role #{name} requires a course"
      end
    else
      if course
        errors.add :course, "Site-wide role #{name} should not have a course"
      end
    end
  end
end
