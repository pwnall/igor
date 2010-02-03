require File.dirname(__FILE__) + '/../test_helper'

class ApiControllerTest < ActionController::TestCase
  fixtures :users, :student_infos, :recitation_conflicts
  
  def check_conflict_info(info)
    assert info, 'Conflict info not present in response'    
    info = info.sort_by { |student| student['athena'] }
    
    golden_dexter = {"athena"=>"genius", "credit"=>true, "conflicts"=>
      [{"timeslot" => 130, "class" => "6.001"},
       {"timeslot" => 132, "class" => "6.002"},
       {"timeslot" => 134, "class" => "6.006"},
       {"timeslot" => 140, "class" => "6.001"},
       {"timeslot" => 142, "class" => "6.002"}]       
    }    
    assert_equal info.first, golden_dexter, "Dexter's conflict information"    
  end
  
  def test_conflict_info_via_json
    get :conflict_info, :format => 'json'
    result = JSON.parse(@response.body)
    assert result, 'Response is not JSON-formatted'
    check_conflict_info result['info']
  end  
end
