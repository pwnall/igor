require 'test_helper'

class TeamPartitionTest < ActiveSupport::TestCase
  def setup
    @admin = users(:admin)
    @psets_partition = team_partitions(:psets)
  end
  
  test "team_for_user for admin on psets" do
    assert_equal teams(:awesome_pset), @psets_partition.team_for_user(@admin)
  end
  
  test "teammates_for_user for admin on psets" do
    assert_equal [users(:dexter)], @psets_partition.teammates_for_user(@admin)
  end
end
