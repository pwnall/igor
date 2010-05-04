# A profile's avatar.
class ProfilePhoto < ActiveRecord::Base
  belongs_to :profile
  
  # The picture bits.
  has_attached_file :pic, :storage => :database, :whiny => true,
      :default_style => :thumb,
      :styles => {
        :thumb => {
          :geometry => '36x36', :format => 'png',
          :convert_options => '-strip'
        },
        :profile => {
          :geometry => '100x100', :format => 'png',
          :convert_options => '-strip'
        }
      }
  validates_attachment_size :less_than => 1.megabyte

  # TODO(costan): filesystem-based caching
end
