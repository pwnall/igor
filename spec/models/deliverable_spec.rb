require 'spec_helper'

describe Deliverable do
#  fixtures :deliverables, :submissions, :users, :team_partitions, :teams,
#           :team_memberships

  # NOTE: specifying individual fixtures makes specs fail on MRI 1.9.2
  fixtures :all
           
  let(:admin) { users(:admin) }
  let(:dexter) { users(:dexter) }
  let(:inactive) { users(:inactive) }
  
  describe 'submission_for' do
    let(:ps1_writeup) { deliverables(:ps1_writeup) }
    let(:admin_ps1) { submissions(:admin_ps1) }
    
    describe 'on a team assignment' do
      it "should find a user's direct submission" do
        ps1_writeup.submission_for(admin).should == admin_ps1
      end
      it "should find a user's teammate's submission" do
        ps1_writeup.submission_for(dexter).should == admin_ps1
      end
      it 'should be nil if nobody in a team submitted' do
        ps1_writeup.submission_for(inactive).should be_nil      
      end 
    end
    
    describe 'on an individual assignment' do
      let(:assessment) { deliverables(:assessment_writeup) }
      
      it 'should find direct submission' do
        assessment.submission_for(admin).should ==
            submissions(:admin_assessment)
      end
      it "should be nil for users who didn't submit" do
        assessment.submission_for(inactive).should be_nil
      end 
    end
  end
end

# == Schema Information
#
# Table name: deliverables
#
#  id            :integer(4)      not null, primary key
#  assignment_id :integer(4)      not null
#  file_ext      :string(16)      not null
#  name          :string(80)      not null
#  description   :string(2048)    not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

