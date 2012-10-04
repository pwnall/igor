require 'spec_helper'

describe "recitation_sections/show" do
  before(:each) do
    @recitation_section = assign(:recitation_section, stub_model(RecitationSection))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
