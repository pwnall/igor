# == Schema Information
# Schema version: 20100504203833
#
# Table name: profile_photos
#
#  id               :integer(4)      not null, primary key
#  profile_id       :integer(4)      not null
#  pic_file_name    :string(256)     not null
#  pic_content_type :string(64)      not null
#  pic_file_size    :integer(4)      not null
#  pic_file         :binary(16777215 default(""), not null
#  pic_profile_file :binary(16777215 default(""), not null
#  pic_thumb_file   :binary(16777215 default(""), not null
#  created_at       :datetime
#  updated_at       :datetime
#

# A profile's avatar.
class ProfilePhoto < ActiveRecord::Base
  # The profile whose avatar is stored by this.
  belongs_to :profile
  validates_presence_of :profile
  
  # The picture bits.
  has_attached_file :pic, :storage => :database,
      :default_style => :thumb, :convert_options => { :all => '-strip' },
      :url => '/:class/:id/:style',
      :styles => {
        :thumb => {
          :geometry => '36x36#', :format => 'png'
        },
        :profile => {
          :geometry => '100x100#', :format => 'png'
        }
      }
  validates_attachment_size :pic, :less_than => 1.megabyte

  # TODO(costan): filesystem-based caching
end
