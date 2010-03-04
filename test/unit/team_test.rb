require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "submissions" do
    assert_equal [submissions(:admin_ps1)],
                 teams(:awesome_pset).submissions.all,
                 'Team awesome for psets'
    assert_equal [submissions(:admin_project)],
                 teams(:boo_project).submissions.all,
                 'Team boo for projects'
    assert_equal [submissions(:inactive_project)],
                 teams(:awesome_project).submissions.all,
                 'Team awesome for projects'
  end
end
