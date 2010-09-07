require 'test_helper'

class ProfilePhotoTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  
  setup do
    @photo = ProfilePhoto.new :profile => profiles(:solo),
        :pic => fixture_file_upload('profile_pics/costan.png','image/png')
  end
  
  test 'setup' do
    assert @photo.valid?
  end
end
