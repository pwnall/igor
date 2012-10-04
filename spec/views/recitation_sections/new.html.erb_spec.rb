require 'spec_helper'

describe "recitation_sections/new" do
  before(:each) do
    assign(:recitation_section, stub_model(RecitationSection).as_new_record)
  end

  it "renders new recitation_section form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => recitation_sections_path, :method => "post" do
    end
  end
end
