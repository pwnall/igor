# == Schema Information
#
# Table name: profile_photos
#
#  id               :integer          not null, primary key
#  profile_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pic_file_name    :string
#  pic_content_type :string
#  pic_file_size    :integer
#  pic_updated_at   :datetime
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

  # The picture bits.
  has_attached_file :pic, storage: :database, database_table: :photo_blobs,
      default_style: :thumb, convert_options: { all: '-strip' },
      url: '/:class/:id/:style',
      styles: {
        thumb: { geometry: '36x36#', format: 'png' },
        profile: { geometry: '100x100#', format: 'png' }
      }
  validates_attachment_size :pic, less_than: 1.megabyte
end
