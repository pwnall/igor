require 'spec_helper'

describe Team do
  fixtures :teams, :submissions, :grades

  let(:psets_team_awesome) { teams(:awesome_pset) }
  let(:project_team_boo) { teams(:boo_project) }
  let(:project_team_awesome) { teams(:awesome_project) }

  describe 'submissions' do
    it 'should only report submissions for related assignments' do
      psets_team_awesome.submissions.all.should == [submissions(:admin_ps1)]
      project_team_awesome.submissions.all.should ==
          [submissions(:inactive_project)]
      project_team_boo.submissions.all.should == [submissions(:admin_project)]
    end
  end

  describe 'grades' do
    it 'should only report grades on connected assignments' do
      psets_team_awesome.grades.all.should == [grades(:awesome_ps1_p1)]
      project_team_awesome.grades.all.should == [grades(:awesome_project)]
      project_team_boo.grades.all.should == [grades(:boo_project)]
    end
  end
end
