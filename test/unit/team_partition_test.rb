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
  
  test "populating new partition" do
    partition = TeamPartition.create :name => 'Cloning'
    partition.populate_from @psets_partition
    
    original_membership = @psets_partition.teams.
        map { |t| [t.name, t.users.map(&:name)] }.sort
    assert_equal original_membership,
                 partition.teams.map { |t| [t.name, t.users.map(&:name)] }.sort,
                 'Team membership'
    assert_equal [],
                 @psets_partition.teams.map(&:id) & partition.teams.map(&:id),
                 'Cloned teams use disjoint records'
    assert_equal [],
                 @psets_partition.teams.map(&:id) & partition.teams.map(&:id),
                 'Cloned memberships use disjoint records'
  end
end
