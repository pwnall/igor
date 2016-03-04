# == Schema Information
#
# Table name: team_memberships
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  user_id    :integer          not null
#  course_id  :integer          not null
#  created_at :datetime
#

# An association showing that a user belongs to a team.
class TeamMembership < ApplicationRecord
  # The team that the user belongs to.
  belongs_to :team
  validates :team, presence: true

  # The user that belongs to a team.
  belongs_to :user, inverse_of: :team_memberships
  validates :user, presence: true, uniqueness: { scope: :team }
  validates_each :user do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif value.teams.find_by partition: record.partition
      record.errors.add attr, 'is already a member in another team'
    elsif record.registration.nil?
      record.errors.add attr, 'is not a registered student'
    end
  end

  # The course of the team's partition.
  #
  # This is redundant, but helps find a student's grades for a specific course.
  belongs_to :course, inverse_of: :team_memberships
  # Get the course, if nil, from the team.
  def get_team_course
    self.course ||= team.course if team
  end
  private :get_team_course
  before_validation :get_team_course

  # Ensures that the course matches the team's course.
  validates_each :course do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.partition.course != value
      record.errors.add attr, "does not match the partition's course"
    end
  end

  # Convenience proxy for the team's partition.
  has_one :partition, through: :team

  # The team member's registration for the team's course.
  def registration
    user.registration_for course
  end
end
