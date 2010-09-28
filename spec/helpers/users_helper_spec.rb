require 'spec_helper'

describe UsersHelper do
  fixtures :users
  
  let(:dexter) { users(:dexter) }
  let(:lurker) { users(:inactive) }
  
  describe 'display_name' do
    it 'should look up profile name' do
      helper.display_name_for_user(dexter).should ==
          'Dexter Boy Genius <genius@mit>'
    end
  end
  
  describe 'user_image_tag' do
    it "should point to the profile's photo if there is one" do
      helper.user_image_tag(dexter).should have_selector('img',
          :alt => 'avatar for dexter',
          :src => thumb_profile_photo_path(dexter.profile.photo))
    end
    
    it "should point to the Gravatar if there's no profile photo" do
      # NOTE: there shouldn't be an &amp; in the URL; it's a Gravatar bug
      helper.user_image_tag(lurker).should have_selector('img',
          :alt => 'avatar for lurker',
          :src => 'https://secure.gravatar.com/avatar/cfe07d554ff4da258e53acf07aad4abb.png?r=G&amp;s=36')
    end
  end
end
