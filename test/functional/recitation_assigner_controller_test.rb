require 'test_helper'

require 'flexmock/test_unit'

class RecitationAssignerControllerTest < ActionController::TestCase
  # This actually tests RecitationAssigner, but needs to fire requests against
  # the API controller.
  tests ApiController
  
  def test_conflicts_info
    get :conflict_info, :format => 'json'
    flexmock(RecitationAssigner).should_receive(:raw_conflicts_info).
                                 and_return(@response.body)
                              
    golden_info = [{:athena=>"genius", :conflicts=>{
      130 => {"timeslot" => 130, "class" => "6.001"},
      132 => {"timeslot" => 132, "class" => "6.002"},
      140 => {"timeslot" => 140, "class" => "6.001"},
      142 => {"timeslot" => 142, "class" => "6.002"}
    }}]

    assert_equal golden_info, RecitationAssigner.conflicts_info
  end
end