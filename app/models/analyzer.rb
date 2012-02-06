# == Schema Information
# Schema version: 20110429122654
#
# Table name: analyzers
#
#  id             :integer(4)      not null, primary key
#  type           :string(32)      not null
#  deliverable_id :integer(4)      not null
#  message_name   :string(64)
#  db_file_id     :integer(4)
#  time_limit     :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

# Performs an automated sanity check on submissions and offers instant feedback.
#
# The sanity check can range from a exhaustive test suite to a simple search for
# the right magic number in the file header. The result 
class Analyzer < ActiveRecord::Base
  # The deliverable whose submissions are sanity-checked.
  belongs_to :deliverable, :inverse_of => :analyzer
  validates :deliverable, :presence => true
  validates :deliverable_id, :uniqueness => true
  
  # Analyzes a student's submission.
  #
  # Returns the Analysis instance containing the result.
  def check(submission)
    raise "Subclass #{self.class.name} did not override #check(submission)."
  end
end
