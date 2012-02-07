require 'spec_helper'

describe TeamPartition do
  fixtures :team_partitions, :teams, :users, :submissions, :grades

  let(:admin) { users(:admin) }  
  let(:dexter) { users(:dexter) }
  let(:psets_partition) { team_partitions(:psets) }

  describe 'team_for_user' do
    it 'should find the team for a user in a partition' do
      psets_partition.team_for_user(admin).should == teams(:awesome_pset)      
    end
  end
  
  describe 'teammates_for_user' do
    it 'should not include the user' do
      psets_partition.teammates_for_user(admin).should == [dexter]
    end
  end
  
  describe 'populate_from' do
    let(:new_partition) { TeamPartition.create :name => 'Cloning' }
    before { new_partition.populate_from psets_partition }
    
    it 'should represent the same mapping' do
      membership_tree(psets_partition).should == membership_tree(new_partition)
    end

    # Canonical representantion of a partition.    
    def membership_tree(partition)
      partition.teams.map { |t| [t.name, t.users.map(&:name).sort] }.sort
    end
    
    it "should not reuse the original partition's team records" do
      (new_partition.teams.map(&:id) &
       psets_partition.teams.map(&:id)).should be_empty
    end
    
    it "should not reuse the original partition's membership records" do
      (new_partition.memberships.map(&:id) &
       psets_partition.memberships.map(&:id)).should be_empty
    end    
  end
end

# == Schema Information
#
# Table name: team_partitions
#
#  id         :integer(4)      not null, primary key
#  name       :string(64)      not null
#  automated  :boolean(1)      default(TRUE), not null
#  editable   :boolean(1)      default(TRUE), not null
#  published  :boolean(1)      default(FALSE), not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

