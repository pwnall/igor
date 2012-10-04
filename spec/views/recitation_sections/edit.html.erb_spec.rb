require 'spec_helper'

describe "recitation_sections/edit" do
  before(:each) do
    @recitation_section = assign(:recitation_section, stub_model(RecitationSection))
  end

  it "renders the edit recitation_section form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => recitation_sections_path(@recitation_section), :method => "post" do
    end
  end
end
