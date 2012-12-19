# == Schema Information
#
# Table name: profile_photos
#
#  id               :integer          not null, primary key
#  profile_id       :integer          not null
#  pic_file_name    :string(256)      not null
#  pic_content_type :string(64)       not null
#  pic_file_size    :integer          not null
#  pic_file         :binary(16777215) default(""), not null
#  pic_profile_file :binary(16777215) default(""), not null
#  pic_thumb_file   :binary(16777215) default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

# A profile's avatar.
class ProfilePhoto < ActiveRecord::Base
  # The profile whose avatar is stored by this.
  belongs_to :profile
  validates_presence_of :profile
  
  # The picture bits.
  has_attached_file :pic, storage: :database,
      default_style: :thumb, convert_options: { all: '-strip' },
      url: '/:class/:id/:style',
      styles: {
        thumb: {
          geometry: '36x36#', format: 'png'
        },
        profile: {
          geometry: '100x100#', format: 'png'
        }
      }
  validates_attachment_size :pic, less_than: 1.megabyte

  # TODO(costan): filesystem-based caching
end
