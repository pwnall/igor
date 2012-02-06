# The description of a file that students must submit for an assignment.
class Deliverable < ActiveRecord::Base
  # The user-visible deliverable name.
  validates :name, :length => 1..64, :presence => true,
                   :uniqueness => { :scope => [:assignment_id] }
  
  # Instructions on preparing submissions for this deliverable.
  validates :description, :length => 1..(2.kilobytes), :presence => true
  
  # Standard filename of the deliverable (e.g. writeup.pdf, trees.py)
  validates :filename, :length => 1..256, :presence => true

  # The assignment that the deliverable is a part of.
  belongs_to :assignment, :inverse_of => :deliverables
  
  # The method used to verify students' submissions for this deliverable.
  has_one :analyzer, :dependent => :destroy,
                               :inverse_of => :deliverable
  
  # All the student submissions for this deliverable.
  has_many :submissions, :dependent => :destroy, :inverse_of => :deliverable
  
  # True if the given user should be allowed to see the deliverable.
  def visible_for?(user)
    assignment.deliverables_ready? || (user && user.admin?)
  end

  # This deliverable's submission for the given user.
  #
  # The result is non-trivial in the presence of teams.
  def submission_for(user)    
    if (partition = assignment.team_partition) and
       (team = partition.team_for_user(user))
      users = team.users
    else
      users = [user]
    end
    
    Submission.where(:deliverable_id => self.id, :user_id => users.map(&:id)).
               first
  end
  
  # The deliverables that a user is allowed to submit.
  def self.submittable_by(user)
    Deliverable.where(user.admin? ? {} : {:published => true})
  end
  
  # The deliverable deadline, customized to a specific user.
  def deadline_for(user)
    assignment.deadline_for user
  end
  
  # True if the submissions for this deliverable should be marked as late.
  def deadline_passed_for?(user)
    assignment.deadline_passed_for? user
  end  
end

# == Schema Information
#
# Table name: deliverables
#
#  id            :integer(4)      not null, primary key
#  assignment_id :integer(4)      not null
#  name          :string(80)      not null
#  description   :string(2048)    not null
#  published     :boolean(1)      default(FALSE), not null
#  filename      :string(256)     default(""), not null
#  created_at    :datetime
#  updated_at    :datetime
#

