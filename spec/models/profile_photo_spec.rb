require 'spec_helper'

describe ProfilePhoto do
  include ActionDispatch::TestProcess  
  fixtures :profile_photos, :profiles
  
  let(:photo) do
    ProfilePhoto.new :profile => profiles(:solo),
        :pic => fixture_file_upload('spec/fixtures/profile_pics/costan.png',
                                    'image/png')
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
