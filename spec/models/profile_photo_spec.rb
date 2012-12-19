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
