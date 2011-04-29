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

# Submission checker that calls a method in SubmissionCheckersController.
class ProcChecker < SubmissionChecker
  # The name of the message to be sent to the controller.
  validates_presence_of :message_name
end
