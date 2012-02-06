# == Schema Information
# Schema version: 20110429122654
#
# Table name: submission_checkers
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

# Method for sanity-checking student submissions.
#
# The sanity-checks can range from a exhaustive test suite to a simple header
# format check.
class SubmissionChecker < ActiveRecord::Base
  # The deliverable whose submissions are sanity-checked.
  belongs_to :deliverable, :inverse_of => :submission_checker
  validates :deliverable, :presence => true
  validates :deliverable_id, :uniqueness => true
  
  # Runs the sanity checks for a student's submission.
  #
  # Returns the Analysiss produced.
  def check(submission)
    raise "Subclass #{self.class.name} did not override #check(submission)."
  end
end
