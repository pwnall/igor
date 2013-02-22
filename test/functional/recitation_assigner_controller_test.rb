require 'test_helper'

class RecitationAssignerControllerTest < ActionController::TestCase
  # This actually tests RecitationAssigner, but needs to fire requests against
  # the API controller.
  
  # TODO FIXME
  
  #tests ApiController
  
  #def test_conflicts_info
  #  get :conflict_info, :format => 'json'
  #  RecitationAssigner.expects(:raw_conflicts_info).returns(@response.body)
  #                            
  #  golden_info = [{:athena=>"genius", :conflicts=>{
  #    130 => {"timeslot" => 130, "class" => "6.001"},
  #    132 => {"timeslot" => 132, "class" => "6.002"},
  #    140 => {"timeslot" => 140, "class" => "6.001"},
  #    142 => {"timeslot" => 142, "class" => "6.002"}
  #  }}]
  #
  #  assert_equal golden_info, RecitationAssigner.conflicts_info
  #end
end