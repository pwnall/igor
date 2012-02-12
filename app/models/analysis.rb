# == Schema Information
#
# Table name: analyses
#
#  id            :integer(4)      not null, primary key
#  submission_id :integer(4)      not null
#  score         :integer(4)
#  diagnostic    :string(256)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  log           :text(16777215)
#

# The result of analyzing a Submission. 
class Analysis < ActiveRecord::Base
  # The submission that was analyzed.
  belongs_to :submission, inverse_of: :analysis
  validates :submission, presence: true
  validates :submission_id, uniqueness: true

  # Grading advice produced by the analyzer.
  validates :score, numericality: { integer_only: true,
      greater_than_or_equal_to: 0, allow_nil: true }
  
  # Analysis result.
  validates :diagnostic, length: { in: 1..256, allow_nil: true }

  # Detailed log of the analysis software.
  validates :log, length: { in: 1..64.kilobytes, allow_nil: true }

  # Analyses aren't editable from Web forms.
  attr_accessible
  
  # Sets fields to reflect that the result is pending a queued check.
  def queued!
    self.diagnostic = 'Queued'
    self.log = self.score = nil
    self.save!
  end
  
  # Sets fields to reflect that the result is pending a running check.
  def running!
    self.diagnostic = 'Running'
    self.log = self.score = nil
    self.save!
  end
  
  # Sets fields to reflect that no analyzer is available for the submission.
  def no_analyzer!
    self.diagnostic = 'No analyzer available'
    self.log = self.score = nil
    self.save!
  end
end
