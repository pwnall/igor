# == Schema Information
# Schema version: 20110429095601
#
# Table name: submissions
#
#  id                :integer(4)      not null, primary key
#  deliverable_id    :integer(4)      not null
#  user_id           :integer(4)      not null
#  code_file_name    :string(256)
#  code_content_type :string(64)
#  code_file_size    :integer(4)
#  code_file         :binary(16777215
#  created_at        :datetime
#  updated_at        :datetime
#

# A file submitted by a student for an assignment.
class Submission < ActiveRecord::Base
  # The submitted file (presumably code).
  has_attached_file :code, :storage => :database
  validates_attachment_presence :code
  validates_attachment_size :code, :less_than => 8.megabytes

  # The user doing the submission.
  belongs_to :user, :inverse_of => :submissions
  validates :user, :presence => true
  
  # The deliverable that the submission is for.
  belongs_to :deliverable
  validates :deliverable, :presence => true
  
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
