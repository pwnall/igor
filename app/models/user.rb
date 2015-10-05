# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  exuid      :string(32)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Virtual email attribute, with validation.
  include Authpwn::UserExtensions::EmailField
  # Virtual password attribute, with confirmation validation.
  include Authpwn::UserExtensions::PasswordField


  # Add your extensions to the User class here.

  # Additional restriction: .edu e-mails only.
  validates :email, format: {
      with: /\A[A-Za-z0-9.+_-]+\@[A-Za-z0-9.\-]+\.edu\Z/,
      message: 'needs to be an .edu e-mail address' }
end

# :nodoc: roles
class User
  # Special privileges for this user.
  has_many :roles, dependent: :destroy, inverse_of: :user

  # The user's requests for privileges.
  has_many :role_requests, dependent: :destroy, inverse_of: :user

  # The courses that this user staffs or grades.
  has_many :staff_courses, through: :roles, source: :course

  # Checks if this user has a privilege.
  #
  # @param [String] role_name the role with the privilege in question
  # @param [Course] course one or more courses in which the user might have the
  #     privileges in question, if checking for course-level roles; nil,
  #     if checking for site-level roles
  # @return [Boolean] true if the user has the given privilege
  def has_role?(role_name, course = nil)
    Role.has_entry? self, role_name, course
  end

  # Checks if the user is a site-wide admin.
  def admin?
    has_role?('admin')
  end

  # Checks if the user is an automated robot.
  def robot?
    has_role? 'bot'
  end

  # The user profile that represents the actions of the site software.
  def self.robot
    @robot ||= Role.find_by!(name: 'bot').user
  end
  @robot = nil
end

# :nodoc: site identity and class membership
class User
  # Personal information, e.g. full name and contact info.
  has_one :profile, dependent: :destroy, inverse_of: :user
  validates :profile, presence: true
  accepts_nested_attributes_for :profile

  # Sort users by name in alphabetical order.
  scope :by_name, -> { includes(:profile).order('profiles.name') }

  # The user's real-life name.
  def name
    profile.name
  end

  # The user's name, suitable to be displayed to the given user.
  #
  # This method should also be defined for Team.
  def display_name_for(other_user = nil, format = :short)
    if self == other_user
      'You'
    elsif format == :short
      name
    elsif format == :long
      "#{name} [#{email}]"
    end
  end

  # Returns true if the given user is allowed to see this user's info.
  def can_read?(user)
    # TODO(pwnall): figure out teams; teammates should see user
    # TODO(pwnall): do admins and course staff get fully visible profiles?
    admin? || user == self || (user && user.admin?)
  end

  # Returns true if the given user is allowed to edit this user's info.
  def can_edit?(user)
    user == self || !!(user && user.admin?)
  end

  # Course registration info, e.g. survey answers and credit / listener status.
  has_many :registrations, dependent: :destroy, inverse_of: :user
  has_many :recitation_sections, through: :registrations

  # The courses in which the student is registered.
  has_many :registered_courses, through: :registrations, source: :course

  # The user's registration for the given course.
  def registration_for(course)
    registrations.find_by course: course
  end

  # The user's recitation section for the given course.
  def recitation_section_for(course)
    recitation_sections.where(course: course).first
  end

  # True if the user is a registered student in the given course.
  #
  # This same method is defined for Team so that the method can be called on
  #     either a Team or User instance.
  def enrolled_in_course?(course)
    !!course && course.is_student?(self)
  end
end

# :nodoc: homework submission feature.
class User
  # Files uploaded by the user to meet assignment deliverables.
  has_many :submissions, dependent: :destroy, inverse_of: :subject, as: :subject

  # Submissions connected to this user.
  #
  # Returns the submissions authored by the user, as well as the submissions
  # authored by the user's teammates.
  def connected_submissions
    submissions = self.submissions
    teams.each { |team| submissions += team.submissions.all }
    submissions
  end

  # The deadline extensions that have been granted to this user.
  has_many :extensions, class_name: 'DeadlineExtension', dependent: :destroy,
      inverse_of: :subject

  # Extensions granted by this user.
  #
  # This association is mostly useful to nullify the grantor field if the user
  # is destroyed.
  has_many :granted_extensions, class_name: 'DeadlineExtension',
      foreign_key: :grantor_id, dependent: :nullify, inverse_of: :grantor

  # Get users without an extension for the given assignment.
  def self.without_extensions_for(assignment)
    where.not id: assignment.extension_recipients
  end

  # The extension, if any, granted for the given assignment.
  def extension_for(assignment)
    extensions.find_by subject: assignment
  end
end

# :nodoc: submission feedback and grading.
class User
  # Grades assigned to the user, not to a team that the user belongs to.
  has_many :direct_grades, class_name: 'Grade', dependent: :destroy,
           as: :subject

  # Comments on the user, not on a team that the user belongs to.
  has_many :direct_comments, class_name: 'GradeComment', dependent: :destroy,
           as: :subject

  # All the grades connected to a user for a given course.
  #
  # The returned set includes the user's direct grades, as well as grades
  # recorded for a team that the user is a part of.
  def grades_for(course)
    direct_grades.where(course: course).includes(metric: :assignment) +
        teams_for(course).includes(grades: { metric: :assignment }).
        map(&:grades).flatten
  end

  # All the comments connected to a user for a given course.
  #
  # The returned set includes the user's direct comments, as well as comments
  # recorded for a team that the user is a part of.
  def comments_for(course)
    direct_comments.where(course: course).includes(metric: :assignment) +
        teams_for(course).includes(comments: { metric: :assignment }).
        map(&:comments).flatten
  end
end

# :nodoc: recitations
class User
  has_many :recitation_assignments, dependent: :destroy, inverse_of: :user

  # Sections led by this user.
  #
  # This association is mostly useful to nullify the leader field if the user
  # is destroyed.
  has_many :led_recitation_sections, class_name: 'RecitationSection',
      foreign_key: :leader_id, dependent: :nullify, inverse_of: :leader
end

# :nodoc: teams feature.
class User
  # Backing model for the teams association.
  has_many :team_memberships, dependent: :destroy, inverse_of: :user

  # Teams that this user belongs to.
  has_many :teams, through: :team_memberships, inverse_of: :users

  # All the teams connected to a user for a given course.
  def teams_for(course)
    Team.joins(:memberships).where team_memberships: { user_id: id,
                                                       course_id: course.id }
  end
end

# :nodoc: feedback survey integration.
class User
  # The user's responses to surveys.
  has_many :survey_responses, dependent: :destroy, inverse_of: :user
end
