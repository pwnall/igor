# == Schema Information
# Schema version: 20110429095601
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
end
