# The description of a file that students must submit for an assignment.
class Deliverable < ActiveRecord::Base
  # The user-visible deliverable name.
  validates :name, :length => 1..64, :presence => true,
                   :uniqueness => { :scope => [:assignment_id] }
  
  # Instructions on preparing submissions for this deliverable.
  validates :description, :length => 1..(2.kilobytes), :presence => true

  # The extension of files to be submitted for this deliverable. (e.g., "pdf")
  validates :file_ext, :length => 1..16, :presence => true
  
  # The assignment that the deliverable is a part of.
  belongs_to :assignment, :inverse_of => :deliverables
  
  # The method used to verify students' submissions for this deliverable.
  has_one :analyzer, :dependent => :destroy, :inverse_of => :deliverable
  accepts_nested_attributes_for :analyzer
  validates_associated :analyzer
  
  # HACK: this nasty bit of code gets nested_attributes working with STI.
  def analyzer_attributes=(attributes)
    type = attributes[Analyzer.inheritance_column]
    attributes = attributes.except Analyzer.inheritance_column, :id
    if type
      klass = Analyzer.send :find_sti_class, type
      if analyzer && !analyzer.kind_of?(klass)
        analyzer.destroy
        self.analyzer = nil
      end
      
      unless analyzer
        self.analyzer = klass.new
        analyzer.deliverable = self
      end
    end
    analyzer.attributes = attributes
  end
  
  # The analyzer, if it's a proc_analyzer.
  has_one :proc_analyzer, :inverse_of => :deliverable
  accepts_nested_attributes_for :proc_analyzer
  
  # The analyzer, if it's a script_analyzer
  has_one :script_analyzer, :inverse_of => :deliverable
  accepts_nested_attributes_for :script_analyzer
  
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
#  file_ext      :string(16)      not null
#  name          :string(80)      not null
#  description   :string(2048)    not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

