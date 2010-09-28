require 'spec_helper'

describe ProfilesHelper do
  let(:mit) { 'Massachusetts Institute of Technology' }
  let(:mit_school) { 'School of Engineering' }
  let(:mit_department) { 'Electrical Eng & Computer Sci' }
  let(:wellesley_address) { '21 Wellesley College Rd #' }
  
  describe 'guess_university_from_athena' do
    it 'should guess mit if the profile has a school' do
      guess_university_from_athena(:school => mit_school,
          :address => wellesley_address).should == mit
    end
        
    it 'should guess mit if the profile has a department' do
      guess_university_from_athena(:department => mit_department,
          :address => wellesley_address).should == mit      
    end

    it 'should guess mit if the profile has a year' do
      guess_university_from_athena(:year => '1',
          :address => wellesley_address).should == mit      
    end

    it 'should guess wellesley first for profile keywords' do
      guess_university_from_athena(:name => 'John Harvard',
          :address => wellesley_address, :city => 'Wellesley, MA').
          should == 'Wellesley College'
    end
    
    it 'should guess harvard last for profile keywords' do
      guess_university_from_athena(:name => 'John Harvard').
          should == 'Harvard University'
    end
  end  
end
