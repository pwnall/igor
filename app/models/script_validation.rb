# == Schema Information
# Schema version: 20110208012638
#
# Table name: deliverable_validations
#
#  id               :integer(4)      not null, primary key
#  type             :string(128)     not null
#  deliverable_id   :integer(4)      not null
#  message_name     :string(64)
#  pkg_uri          :string(1024)
#  pkg_tag          :string(64)
#  pkg_file_name    :string(256)
#  pkg_content_type :string(64)
#  pkg_file_size    :integer(4)
#  pkg_file         :binary(21474836
#  time_limit       :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'digest/sha2'

# Submission validation that runs an external script.
class ScriptValidation < DeliverableValidation
  # The maximum time to run the validation for.
  validates :time_limit, :presence => true,
                         :numericality => { :only_integer => true }

  # The uploaded validation script.
  has_attached_file :pkg, :storage => :database
  
  # The uploaded validation script.
  validates_attachment_presence :pkg
end
