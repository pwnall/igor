# == Schema Information
# Schema version: 20100208065707
#
# Table name: assignments
#
#  id                :integer(4)      not null, primary key
#  deadline          :datetime        not null
#  name              :string(64)      not null
#  team_partition_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

# An assignment for the course students. (e.g., a problem set or a project)
class Assignment < ActiveRecord::Base
  has_many :deliverables, :dependent => :destroy
  has_many :assignment_metrics, :dependent => :destroy
  
  # The user-visible assignment name (e.g., "PSet 1").
  validates_length_of :name, :in => 1..64, :allow_nil => false
  validates_uniqueness_of :name
  
  # The time when all the deliverables of the assignment are due.
  validates_presence_of :deadline

  # The partition of teams used for this assignment.
  belongs_to :team_partition
end
