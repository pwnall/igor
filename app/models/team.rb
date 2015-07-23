# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  partition_id :integer          not null
#  name         :string(64)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# A team in the class.
#
# The system supports multiple partitions of students into teams.
class Team < ActiveRecord::Base
  # The team's user-visible name.
  validates :name, length: 1..64, presence: true,
                   uniqueness: { scope: [:partition_id] }

  # The partition that this team is part of.
  belongs_to :partition, class_name: 'TeamPartition', inverse_of: :teams
  validates :partition, presence: true

  # The memberships connecting users to this team.
  has_many :memberships, class_name: 'TeamMembership',
                         dependent: :destroy

  # The users in this team.
  has_many :users, through: :memberships, inverse_of: :teams

  # The grades assigned to this team.
  has_many :grades, dependent: :destroy, as: :subject

  # Submissions by this team's members to this team's assignments.
  has_many :submissions, dependent: :destroy, inverse_of: :subject,
           as: :subject

  # The course of the team's partition.
  has_one :course, through: :partition

  # Returns true if the given user is allowed to edit this team's membership.
  def can_edit?(user)
    course.can_edit? user
  end

  def size
    memberships.count
  end

  def min_size
    partition.min_size
  end

  def max_size
    partition.max_size
  end

  def has_user?(user)
    memberships.where(user: user).count != 0
  end
end
