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
  
  # The assignment that this submission is for.
  has_one :assignment, :through => :deliverable

  # Diagnostic issued by the deliverable's SubmissionChecker.
  has_one :check_result, :dependent => :destroy, :inverse_of => :submission

  # Can performs an automated health-check for this submission.
  has_one :submission_checker, :through => :deliverable
  
  # Queues up an automated health-check for this submission.
  def queue_checker
    self.check_result ||= CheckResult.new :submission => self
    self.check_result.queued!
    self.delay.run_checker
  end
  
  # Runs an automated health-check for this submission.
  def run_checker
    self.check_result ||= CheckResult.new :submission => self
    if submission_checker
      self.check_result.running!
      submission_checker.check self
    else
      self.check_result.no_checker!
    end
  end
end
