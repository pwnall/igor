require 'spec_helper'

describe "RecitationSections" do
  describe "GET /recitation_sections" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get recitation_sections_path
      response.status.should be(200)
    end
  end
end
