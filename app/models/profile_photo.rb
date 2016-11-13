# == Schema Information
#
# Table name: profile_photos
#
#  id                  :integer          not null, primary key
#  profile_id          :integer          not null
#  image_blob_id       :string(48)       not null
#  image_size          :integer          not null
#  image_mime_type     :string(64)       not null
#  image_original_name :string(256)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# A profile's avatar.
#
# TODO(spark008): Re-implement this feature. Support for user-uploaded profile
#     pictures has been removed from the UI, and completely replaced with
#     Gravatar. The backend was written for user-uploaded files and is
#     deprecated.
class ProfilePhoto < ApplicationRecord
  # The profile whose avatar is stored by this.
  belongs_to :profile, inverse_of: :photo
  validates :profile, presence: true

  # The wrapped file.
  has_file_blob :image, allows_nil: false, blob_model: 'FileBlob'

  # Refuse to serve active content from the site.
  validates :image_mime_type, exclusion: {
      in: ['text/html', 'application/xhtml+xml'] }
end
