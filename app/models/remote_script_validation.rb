# == Schema Information
# Schema version: 20100203124712
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
#  pkg_medium_file  :binary
#  pkg_thumb_file   :binary
#  time_limit       :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

# Submission validation that runs a script fetched from a remote server.
class RemoteScriptValidation < DeliverableValidation
  # The URI to fetch the script from.
  validates_presence_of :pkg_uri
  
  # A digest of the file contents, for download caching.
  validates_presence_of :pkg_tag
end
