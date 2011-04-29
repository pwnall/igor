# == Schema Information
# Schema version: 20110429122654
#
# Table name: check_results
#
#  id            :integer(4)      not null, primary key
#  submission_id :integer(4)      not null
#  score         :integer(4)
#  diagnostic    :string(256)
#  stdout        :binary(16777215
#  stderr        :binary(16777215
#  created_at    :datetime
#  updated_at    :datetime
#

# Diagnostic issued by a SubmissionChecker for a Submission.
class CheckResult < ActiveRecord::Base
  belongs_to :submission, :inverse_of => :check_result
  validates :submission, :presence => true
  validates :submission_id, :uniqueness => true
  
  # Sets fields to reflect that the result is pending a queued check.
  def queued!
    self.diagnostic = 'queued'
    self.stdout = self.stderr = self.score = nil
    self.save!
  end
  
  # Sets fields to reflect that the result is pending a running check.
  def running!
    self.diagnostic = 'running'
    self.stdout = self.stderr = self.score = nil
    self.save!
  end
  
  # Sets fields to reflect that no checker is available for the submission.
  def no_checker!
    self.diagnostic = 'no checker available'
    self.stdout = self.stderr = self.score = nil
    self.save!
  end
end
