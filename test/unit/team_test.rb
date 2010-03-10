require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "submissions" do
    assert_equal [submissions(:admin_ps1)],
                 teams(:awesome_pset).submissions.all,
                 'Team awesome for psets'
    assert_equal [submissions(:admin_project)],
                 teams(:boo_project).submissions.all,
                 'Team boo for project'
    assert_equal [submissions(:inactive_project)],
                 teams(:awesome_project).submissions.all,
                 'Team awesome for project'
  end
  
  test "grades" do
    assert_equal [grades(:awesome_ps1_p1)], teams(:awesome_pset).grades,
                 'Team awesome for psets'
    assert_equal [grades(:awesome_project)], teams(:awesome_project).grades,
                 'Team awesome for project'
    assert_equal [grades(:boo_ps1_p1)], teams(:boo_pset).grades,
                 'Team boo for psets'
    assert_equal [grades(:boo_project)], teams(:boo_project).grades,
                 'Team boo for project'
  end
end
