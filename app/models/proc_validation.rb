# == Schema Information
# Schema version: 18
#
# Table name: deliverable_validations
#
#  id               :integer(4)      not null, primary key
#  deliverable_id   :integer(4)      not null
#  type             :string(128)     not null
#  message_name     :string(64)
#  file_uri         :string(1024)
#  file_tag         :string(64)
#  pkg_file_name    :string(255)
#  pkg_content_type :string(255)
#  pkg_file_size    :integer(4)
#  pkg_file         :binary(21474836
#  pkg_medium_file  :binary
#  pkg_thumb_file   :binary
#  time_limit       :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

# Submission validation that calls a method in DeliverableValidationsController.
class ProcValidation < DeliverableValidation
  # The name of the message to be sent to the controller.
  validates_presence_of :message_name
end
