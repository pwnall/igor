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
  
  # The submissions of this team.
  def submissions
    Submission.where(user_id: memberships.map(&:user_id),
                     deliverable_id: partition.deliverables.map(&:id))
  end
  
  # Returns true if the given user is allowed to edit this team's membership.  
  def can_edit?(user)
    user.admin?
  end
end
