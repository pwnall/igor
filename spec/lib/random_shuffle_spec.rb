require 'spec_helper'

describe RandomShuffle do
  let(:array) { (1..100).to_a }
  
  before do
    @arrays = {}
  end
  
  it 'should generate different permutations when called 1000 times' do
    1000.times do
      array2 = array.dup
      
      RandomShuffle.shuffle! array2
      array2.sort.should == array
      @arrays.should_not have_key(array2)
      
      @arrays[array2] = true
    end
  end
end
