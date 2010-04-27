# == Schema Information
# Schema version: 20100427075741
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

class DeliverableValidation < ActiveRecord::Base
  # The deliverable whose submissions are validated by this validation.
  belongs_to :deliverable

  # The maximum time to run the validation for.
  #
  # This was mainly intended for running user programs.
  validates_numericality_of :time_limit, :only_integer => true,
                                         :allow_nil => true
end
