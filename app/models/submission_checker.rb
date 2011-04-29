# == Schema Information
# Schema version: 20110429095601
#
# Table name: submission_checkers
#
#  id               :integer(4)      not null, primary key
#  type             :string(32)      not null
#  deliverable_id   :integer(4)      not null
#  message_name     :string(64)
#  pkg_file_name    :string(256)
#  pkg_content_type :string(64)
#  pkg_file_size    :integer(4)
#  pkg_file         :binary(21474836
#  time_limit       :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
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
  # Returns the CheckResults produced.
  def check(submission)
    
  end
end
