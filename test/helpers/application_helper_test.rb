require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  describe '#main_section_width_class' do
    before { @view_flow = ActionView::OutputFlow.new }

    it 'returns a 7-column style when the template has a sidebar' do
      content_for :sidebar, 'sidebar'
      assert_equal 'small-7', main_section_width_class
    end

    it 'returns a 10-column style when the template has no sidebar' do
      assert_nil content_for(:sidebar)
      assert_equal 'small-10', main_section_width_class
    end
  end
end
