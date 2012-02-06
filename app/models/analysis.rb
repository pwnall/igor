# The result of analyzing a Submission. 
class Analysis < ActiveRecord::Base
  belongs_to :submission, :inverse_of => :analysis
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
