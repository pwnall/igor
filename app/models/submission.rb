# == Schema Information
# Schema version: 20110429122654
#
# Table name: submissions
#
#  id             :integer(4)      not null, primary key
#  deliverable_id :integer(4)      not null
#  user_id        :integer(4)      not null
#  db_file_id     :integer(4)      not null
#  created_at     :datetime
#  updated_at     :datetime
#

# A file submitted by a student for an assignment.
class Submission < ActiveRecord::Base
  # The user doing the submission.
  belongs_to :user, :inverse_of => :submissions
  validates :user, :presence => true
  
  # The deliverable that the submission is for.
  belongs_to :deliverable
  validates :deliverable, :presence => true
  
  # The database-backed file holding the submission.
  belongs_to :db_file, :dependent => :destroy, :autosave => true
  validates :db_file, :presence => true
  accepts_nested_attributes_for :db_file
  
  # Database-backed file association, including the file contents.
  def full_db_file
    DbFile.unscoped.where(:id => db_file_id).first
  end
  
  # The assignment that this submission is for.
  has_one :assignment, :through => :deliverable

  # Diagnostic issued by the deliverable's Analyzer.
  has_one :analysis, :dependent => :destroy, :inverse_of => :submission

  # Can performs an automated health-check for this submission.
  has_one :submission_checker, :through => :deliverable
  
  # Queues up an automated health-check for this submission.
  def queue_checker
    self.analysis ||= Analysis.new :submission => self
    self.analysis.queued!
    self.delay.run_checker
  end
  
  # Runs an automated health-check for this submission.
  def run_checker
    self.analysis ||= Analysis.new :submission => self
    if submission_checker
      self.analysis.running!
      submission_checker.check self
    else
      self.analysis.no_checker!
    end
  end
end
