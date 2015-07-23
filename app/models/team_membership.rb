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
class TeamMembership < ActiveRecord::Base
  # The team that the user belongs to.
  belongs_to :team
  validates_presence_of :team

  # The user that belongs to a team.
  belongs_to :user, inverse_of: :team_memberships
  validates :user, presence: true
  validates :user_id, uniqueness: { scope: [:team_id] }

  # The course of the team's partition.
  #
  # This is redundant, but helps find a student's grades for a specific course.
  belongs_to :course, inverse_of: :team_memberships
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
