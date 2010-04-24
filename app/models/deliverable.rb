# == Schema Information
# Schema version: 20100216020942
#
# Table name: deliverables
#
#  id            :integer(4)      not null, primary key
#  assignment_id :integer(4)      not null
#  name          :string(80)      not null
#  description   :string(2048)    not null
#  published     :boolean(1)      not null
#  filename      :string(256)     default(""), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class Deliverable < ActiveRecord::Base
  # The assignment that the deliverable is a part of.
  belongs_to :assignment
    
  # The user-visible assignment name.
  validates_length_of :name, :in => 1..64, :allow_nil => false
  # 
  validates_length_of :description, :in => 1..(2.kilobytes), :allow_nil => false

  # The method used to verify students' submissions for this deliverable.
  has_one :deliverable_validation, :dependent => :destroy
  
  # All the student submissions for this deliverable.
  has_many :submissions, :dependent => :destroy

  # This deliverable's submission for the given user.
  #
  # The result is non-trivial in the presence of teams.
  def submission_for_user(user)    
    if partition = assignment.team_partition
      users = partition.team_for_user(user).users
    else
      users = [user]
    end
    
    Submission.where(:deliverable_id => self.id, :user_id => users.map(&:id)).
               first
  end
end
