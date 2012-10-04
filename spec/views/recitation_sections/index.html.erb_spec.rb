require 'spec_helper'

describe "recitation_sections/index" do
  before(:each) do
    assign(:recitation_sections, [
      stub_model(RecitationSection),
      stub_model(RecitationSection)
    ])
  end

  it "renders a list of recitation_sections" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
