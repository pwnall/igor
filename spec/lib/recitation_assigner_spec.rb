require 'spec_helper'

describe RecitationAssigner do
  fixtures :users, :profiles, :registrations
  
  let(:initial_graph) do
    {:vertices => [:sink, :source, 'a', 'b', 'c', 'd'],
     :edges => { :source => {'a' => 0, 'c' => 0},
                 'a' => {'b' => 1, 'd' => 3}, 'c' => {'b' => 2},
                 'b' => {:sink => 0}, 'd' => {:sink => 0}}}
  end
  let(:initial_path) { [[:source, 'a'], ['a', 'b'], ['b', :sink]] }
  
  # initial_graph augmented by initial_path 
  let(:step2_graph) do
    {:vertices => [:sink, :source, 'a', 'b', 'c', 'd'],
     :edges => { :source => {'c' => 0},
                 'a' => {:source => 0, 'd' => 3}, 'c' => {'b' => 2},
                 'b' => {'a' => -1}, 'd' => {:sink => 0},
                 :sink => {'b' => 0}}}
  end
  let(:step2_path) do
    [[:source, 'c'], ['c', 'b'], ['b', 'a'], ['a', 'd'], ['d', :sink]]
  end
  let(:step2_matching) { {'a' => 'b'} }
  
  # step2_graph augmented by step2_path; fully saturated
  let(:step3_graph) do
    {:vertices => [:sink, :source, 'a', 'b', 'c', 'd'],
     :edges => { :source => {},
                 'a' => {:source => 0, 'b' => 1}, 'c' => {:source => 0},
                 'b' => {'c' => -2}, 'd' => {'a' => -3},
                 :sink => {'b' => 0, 'd' => 0}}}
  end
  let(:step3_matching) { {'a' => 'd', 'c' => 'b'} }
  
  describe 'augmenting_path' do
    it 'should find the lowest cost path in an graph with no assignments' do
      RecitationAssigner.augmenting_path(initial_graph).should == initial_path
    end    
    it 'should find the low-cost path using the residual graph in step 2' do
      RecitationAssigner.augmenting_path(step2_graph).should == step2_path
    end
    
    it 'should be nil for saturated graphs' do
      RecitationAssigner.augmenting_path(step3_graph).should be_nil
    end
  end
  
  describe 'augment_path' do
    it 'should create a residual network for the initial graph' do
      g = dclone initial_graph
      RecitationAssigner.augment_flow_graph! g, initial_path
      g.should == step2_graph
    end
    it 'should update the residual network properly in step 2' do
      g = dclone step2_graph
      RecitationAssigner.augment_flow_graph! g, step2_path
      g.should == step3_graph
    end
  end
  
  def dclone(object)
    Marshal.load(Marshal.dump(object))
  end  
  
  describe 'matching_in_graph' do
    it 'should be empty for the initial graph' do
      RecitationAssigner.matching_in(initial_graph).should be_empty
    end

    it 'should distinguish between the main and the residual graph in step2' do
      RecitationAssigner.matching_in(step2_graph).should == step2_matching
    end

    it 'should find the full matching in step3' do
      RecitationAssigner.matching_in(step3_graph).should == step3_matching
    end
  end
  
  describe 'best_matching!' do
    it 'should walk through all steps' do
      g = dclone initial_graph
      RecitationAssigner.best_matching!(g).should == step3_matching      
    end
  end
  
  describe 'on fake example' do
    let(:conflicts) do
      [{:athena => 'ben',
        :conflicts => {102 => true, 124 => true, 131 => true}},
       {:athena => 'genius',
        :conflicts => {130 => true, 132 => true, 140 => true, 142 => true}},
      ]
    end
    let(:section_times) { [10, 12, 13] }
    let(:section_days) { [2, 4] }
    let(:section_seats) { [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] }
    
    describe 'assignment_graph' do
      let(:graph) do
        RecitationAssigner.assignment_graph 4, section_days, section_times,
                                            conflicts
      end    
      it 'should have vertices for all times' do
        graph[:vertices].should =~ [:sink, :source, 'ben', 'genius'] +
            section_seats
      end
      it 'should have all edges coming from valid vertices' do
        graph[:vertices].should include(*graph[:edges].keys)
      end
      it 'should have all edges pointing to valid vertices' do
        graph[:vertices].should include(*graph[:edges].values.map(&:keys).
                                                       flatten.uniq)
      end
      it 'should have edges from source to users' do
        graph[:edges][:source].should == {'ben' => 0, 'genius' => 0}
      end
      it 'should have edges from all seats to sink' do
        section_seats.each { |s| graph[:edges][s].should == { :sink => 0 } }
      end
      it 'should only connect ben to seats in the 13:00 section' do
        graph[:edges]['ben'].should == ({8 => 0, 9 => 0, 10 => 0, 11 => 0})
      end
      it 'should connect dexter to seats in the 10:00 and 12:00 sections' do
        graph[:edges]['genius'].should ==
            ({0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0})
      end
    end
    
    describe 'assignment' do
      let(:matching) do
        RecitationAssigner.assignment 1, section_days, section_times, conflicts
      end
      
      it 'should reflect user conflicts' do
        matching.should == {'ben' => 13, 'genius' => 10}
      end
    end
    
    describe 'inverted assignment' do
      let(:assignment) do
        { 'a' => 10, 'b' => 11, 'c' => 11, 'd' => 12, 'e' => 10 }
      end
      let(:inverted) { {10 => ['a', 'e'], 11 => ['b', 'c'], 12 => ['d']} }
            
      it 'should work on multi-assignments' do
        RecitationAssigner.inverted_assignment(assignment).should == inverted
      end
    end
  end
end
