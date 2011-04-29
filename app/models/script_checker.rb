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

require 'digest/sha2'

# Submission checker that runs an external script.
class ScriptChecker < SubmissionChecker
  # The maximum time that the checker script is allowed to run.
  validates :time_limit, :presence => true,
                         :numericality => { :only_integer => true }

  # The uploaded checler script.
  has_attached_file :pkg, :storage => :database
  validates_attachment_presence :pkg
end
