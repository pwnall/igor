# == Schema Information
# Schema version: 20100504203833
#
# Table name: teams
#
#  id           :integer(4)      not null, primary key
#  partition_id :integer(4)      not null
#  name         :string(64)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

# A team in the class.
#
# The system supports multiple partitions of students into teams. 
class Team < ActiveRecord::Base
  # The partition that this team is part of.
  belongs_to :partition, :class_name => 'TeamPartition'
  validates_presence_of :partition
  
  # The team's user-visible name.
  validates_length_of :name, :in => 1..64
  validates_uniqueness_of :name, :scope => [:partition_id]
  
  # The memberships connecting users to this team.
  has_many :memberships, :class_name => 'TeamMembership', :dependent => :destroy
  
  # The users in this team.  
  has_many :users, :through => :memberships
  
  # The grades assigned to this team.
  has_many :grades, :dependent => :destroy, :as => :subject
  
  # The submissions of this team.
  def submissions
    Submission.where(:user_id => memberships.map(&:user_id),
                     :deliverable_id => partition.deliverables.map(&:id))
  end
end
