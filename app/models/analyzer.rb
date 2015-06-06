# == Schema Information
#
# Table name: analyzers
#
#  id             :integer          not null, primary key
#  deliverable_id :integer          not null
#  type           :string(32)       not null
#  auto_grading   :boolean          default(FALSE), not null
#  exec_limits    :text(65535)
#  db_file_id     :integer
#  message_name   :string(64)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Performs an automated sanity check on submissions and offers instant feedback.
#
# The sanity check can range from a exhaustive test suite to a simple search for
# the right magic number in the file header. The result 
class Analyzer < ActiveRecord::Base
  # The deliverable whose submissions are sanity-checked.
  belongs_to :deliverable, inverse_of: :analyzer
  validates :deliverable, presence: true
  validates :deliverable_id, uniqueness: true
  
  # If true, the analyzer can automatically update the student's grades.
  validates :auto_grading, inclusion: { in: [true, false] }
  #attr_accessible :auto_grading
  
  # Sanity-checks a student's submission.
  #
  # Returns the Analysis instance containing the result.
  def analyze(submission)
    raise "Subclass #{self.class.name} did not override #check(submission)."
  end
end
