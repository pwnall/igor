# == Schema Information
#
# Table name: analyses
#
#  id            :integer(4)      not null, primary key
#  submission_id :integer(4)      not null
#  score         :integer(4)
#  diagnostic    :string(256)
#  stdout        :binary(16777215
#  stderr        :binary(16777215
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

# The result of analyzing a Submission. 
class Analysis < ActiveRecord::Base
  belongs_to :submission, :inverse_of => :analysis
  validates :submission, :presence => true
  validates :submission_id, :uniqueness => true
  
  # Sets fields to reflect that the result is pending a queued check.
  def queued!
    self.diagnostic = 'Queued'
    self.stdout = self.stderr = self.score = nil
    self.save!
  end
  
  # Sets fields to reflect that the result is pending a running check.
  def running!
    self.diagnostic = 'Running'
    self.stdout = self.stderr = self.score = nil
    self.save!
  end
  
  # Sets fields to reflect that no analyzer is available for the submission.
  def no_analyzer!
    self.diagnostic = 'No analyzer available'
    self.stdout = self.stderr = self.score = nil
    self.save!
  end
end
