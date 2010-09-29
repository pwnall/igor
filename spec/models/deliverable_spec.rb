require 'spec_helper'

describe Deliverable do
  fixtures :deliverables, :submissions, :users, :team_partitions, :teams,
           :team_memberships
           
  let(:admin) { users(:admin) }
  let(:dexter) { users(:dexter) }
  let(:inactive) { users(:inactive) }
  
  describe 'submission_for_user' do
    let(:ps1_writeup) { deliverables(:ps1_writeup) }
    let(:admin_ps1) { submissions(:admin_ps1) }
    
    describe 'on a team assignment' do
      it "should find a user's direct submission" do
        ps1_writeup.submission_for_user(admin).should == admin_ps1
      end
      it "should find a user's teammate's submission" do
        ps1_writeup.submission_for_user(dexter).should == admin_ps1
      end
      it 'should be nil if nobody in a team submitted' do
        ps1_writeup.submission_for_user(inactive).should be_nil      
      end 
    end
    
    describe 'on an individual assignment' do
      let(:assessment) { deliverables(:assessment_writeup) }
      
      it 'should find direct submission' do
        assessment.submission_for_user(admin).should ==
            submissions(:admin_assessment)
      end
      it "should be nil for users who didn't submit" do
        assessment.submission_for_user(inactive).should be_nil
      end 
    end
  end
end
