# == Schema Information
#
# Table name: profile_photos
#
#  id               :integer          not null, primary key
#  profile_id       :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#  pic_file_name    :string(255)
#  pic_content_type :string(255)
#  pic_file_size    :integer
#  pic_updated_at   :datetime
#

require 'spec_helper'

describe ProfilePhoto do
  include ActionDispatch::TestProcess  
  fixtures :profile_photos, :profiles
  
  let(:photo) do
    ProfilePhoto.new :profile => profiles(:solo),
        :pic => fixture_file_upload('/profile_pics/costan.png', 'image/png')
  end
  
  it 'should validate proper uploads' do
    photo.should be_valid
  end
  
  it 'should save proper uploads' do
    lambda {
      photo.save!
    }.should change(ProfilePhoto, :count).by(1)
  end
end
