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

# Describes a method to check students' submissions for a deliverable.
class DeliverableValidation < ActiveRecord::Base
  # The deliverable whose submissions are validated by this validation.
  belongs_to :deliverable, :inverse_of => :deliverable_validation
  validates :deliverable, :presence => true
end
