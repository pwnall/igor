require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  before do
    @team = Team.new partition: team_partitions(:psets), name: 'A-Team'
  end

  let(:team) { teams(:awesome_pset) }

  it 'validates the setup team' do
    assert @team.valid?
  end

  it 'requires a partition' do
    @team.partition = nil
    assert @team.invalid?
  end

  it 'requires a name' do
    @team.name = nil
    assert @team.invalid?
  end

  describe 'enrolled_in_course?' do
    it "returns true if the team's partition belongs to the course" do
      assert_equal true, team.enrolled_in_course?(courses(:main))
      assert_equal false, team.enrolled_in_course?(courses(:not_main))
      assert_equal false, team.enrolled_in_course?(nil)
    end
  end
end
