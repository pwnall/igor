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

  # Checks if this user has a privilege.
  def has_role?(role_name, course = nil)
    Role.has_entry? self, role_name, course
  end

  # Checks if the user is a site-wide admin.
  def admin?
    return true if has_role?('admin')

    # HACK(pwnall): remove this when the rest of the code checks for the
    #               correct privileges
    has_role?('staff', Course.main)
  end

  # Checks if the user is an automated robot.
  def robot?
    has_role? 'bot'
  end

  # The user profile that represents the actions of the site software.
  def self.robot
    @robot ||= Role.where(name: 'bot').first!.user
  end
  @robot = nil
end

# :nodoc: site identity and class membership
class User
  # Personal information, e.g. full name and contact info.
  has_one :profile, dependent: :destroy, inverse_of: :user
  validates_associated :profile, on: :create
  validates :profile, presence: { on: :create }

  accepts_nested_attributes_for :profile

  # The user's real-life name.
  #
  # May return the user's e-mail if the user managed to register without
  # creating a profile.
  def name
    (profile && profile.name) || email
  end

  # The user's athena ID.
  #
  # Athena IDs are MIT-specific. New code should avoid them and use full e-mail
  # addresses instead.
  #
  # Returns the email username if the user has not created a profile.
  def athena_id
    (profile && profile.athena_username) || email[0, email.index(?@)]
  end

  # The user's name, suitable to be displayed to the given user.
  def display_name_for(other_user = nil, identity_value = 'You')
    if self == other_user
      identity_value
    elsif profile
      # TODO(pwnall): look at the other user's network, and if we're the only
      #               user with a given first name, return the first name
      name
    else
      name
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
    user == self || (user && user.admin?)
  end

  # Class registration info, e.g. survey answers and credit / listener status.
  has_many :registrations, dependent: :destroy, inverse_of: :user
  has_many :recitation_sections, through: :registrations

  # The courses in which the student is registered.
  has_many :courses, through: :registrations

  # The user's registration for the main class on this site.
  def registration
    registrations.where(course_id: Course.main.id).first
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
end

# :nodoc: grade submission and publishing feature.
class User
  # Grades assigned to the user, not to a team that the user belongs to.
  has_many :direct_grades, class_name: 'Grade', dependent: :destroy,
           as: :subject

  # All the grades connected to a user.
  #
  # The returned set includes the user's direct grades, as well as grades
  # recorded for a team that the user is a part of.
  def grades
    direct_grades.includes(metric: :assignment) +
        teams.includes(grades: {metric: :assignment}).
              map(&:grades).flatten
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

  def recitation_section
    registration && registration.recitation_section
  end
end

# :nodoc: teams feature.
class User
  # Backing model for the teams association.
  has_many :team_memberships, dependent: :destroy, inverse_of: :user

  # Teams that this user belongs to.
  has_many :teams, through: :team_memberships, inverse_of: :users
end

# :nodoc: feedback survey integration.
class User
  # The user's answers to surveys.
  has_many :survey_answers, dependent: :destroy, inverse_of: :user
end

# :nodoc: TeamPartition / Teams searching.
class User
  def team_in_partition(id)
    tms = TeamMembership.where(:user_id => self.id)
    tms.each do |tm|
      if tm.team.partition.id.to_i == id.to_i
        return tm
      end
    end
    return nil
  end
end
