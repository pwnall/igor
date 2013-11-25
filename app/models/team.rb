# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  partition_id :integer          not null
#  name         :string(64)       not null
#  created_at   :datetime
#  updated_at   :datetime
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


  has_many :submissions, dependent: :destroy, inverse_of: :subject, as: :subject


  # The submissions of this team.
  def submissions
    Submission.where(subject_id: memberships.map(&:user_id), subject_type: "team",
                     deliverable_id: partition.deliverables.map(&:id))
  end

  # Returns true if the given user is allowed to edit this team's membership.
  def can_edit?(user)
    user.admin?
  end

  def size
    TeamMembership.count(:conditions => ["team_id = ?", self.id])
  end

  def min_size
    min = TeamPartition.find_by_id(self.partition_id).min_size
    if min.nil?
      return 0
    end
    return min.to_i
  end

  def max_size
    max = TeamPartition.find_by_id(self.partition_id).max_size
    if max.nil?
      return 1.0/0.0 ## Infinity hackery
    end
    return max.to_i
  end

  def has_user?(user)
    memberships.where(:user_id => user.id).count != 0
  end
end
