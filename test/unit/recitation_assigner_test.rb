require 'test_helper'

require 'set'

class RecitationAssignerTest < ActiveSupport::TestCase
  def setup
    # Clean initial matching graph.
    @graph1 = {:vertices => [:sink, :source, 'a', 'b', 'c', 'd'],
               :edges => { :source => {'a' => 0, 'c' => 0},
                           'a' => {'b' => 0, 'd' => 0},
                           'c' => {'b' => 0},
                           'b' => {:sink => 0}, 'd' => {:sink => 0}}}
    @graph1_path = [[:source, 'a'], ['a', 'b'], ['b', :sink]]
    @graph1_matching = {}
                           
    # Unique augmenting path available, using residual network.
    # Obtained by augmenting @graph1 with @graph1_path.
    @graph2 = {:vertices => [:sink, :source, 'a', 'b', 'c', 'd'],
               :edges => { :source => {'c' => 0},
                           'a' => {:source => 0, 'd' => 0},
                           'c' => {'b' => 0},
                           'b' => {'a' => 0}, 'd' => {:sink => 0},
                           :sink => {'b' => 0}}}
    @graph2_path = [[:source, 'c'], ['c', 'b'], ['b', 'a'], ['a', 'd'],
                    ['d', :sink]]
    @graph2_matching = {'a' => 'b'}
    
    # Fully saturated matching graph.
    # Obtained by augmenting @graph2 with @graph2_path
    @graph3 = {:vertices => [:sink, :source, 'a', 'b', 'c', 'd'],
               :edges => { :source => {},
                           'a' => {:source => 0, 'b' => 0},
                           'c' => {:source => 0},
                           'b' => {'c' => 0}, 'd' => {'a' => 0},
                           :sink => {'b' => 0, 'd' => 0}}}
    @graph3_matching = {'a' => 'd', 'c' => 'b'}
  end
  
  def test_augmenting_path_easy
    path = RecitationAssigner.augmenting_path @graph1
    check_augmenting_path @graph1, path    
  end
  
  def test_augmenting_path_residual
    assert_equal @graph2_path, RecitationAssigner.augmenting_path(@graph2)
  end
  
  def test_augmenting_path_saturated
    assert_equal nil, RecitationAssigner.augmenting_path(@graph3)
  end
  
  def check_augmenting_path(graph, path)
    assert_equal :source, path.first.first,
                 "Path does not start at source: #{path.inspect}"
    assert_equal :sink, path.last.last,
                 "Path does not end at sink: #{path.inspect}"
    
    path.each_with_index do |edge, index|
      assert graph[:edges][edge.first][edge.last],
             "Inexistent edge #{edge.inspect} in path #{path.inspect}"
      next if index == 0
      assert_equal path[index - 1].last, edge.first,
                   "Path breaks up at edge #{index}: #{path.inspect}"      
    end
  end
  
  def test_augment_flow_graph_easy
    RecitationAssigner.augment_flow_graph! @graph1, @graph1_path
    assert_equal @graph2, @graph1
  end
  
  def test_augment_flow_graph_residual
    RecitationAssigner.augment_flow_graph! @graph2, @graph2_path
    assert_equal @graph3, @graph2
  end
  
  def test_matching_in_graph_easy
    assert_equal @graph1_matching, RecitationAssigner.matching_in_graph(@graph1)
  end
  
  def test_matching_in_graph_residual
    assert_equal @graph2_matching, RecitationAssigner.matching_in_graph(@graph2)
  end
  
  def test_matching_in_graph_saturated
    assert_equal @graph3_matching, RecitationAssigner.matching_in_graph(@graph3)
  end
  
  def test_best_matching
    assert_equal @graph3_matching, RecitationAssigner.best_matching!(@graph1)
  end
  
  def test_assignment_graph
    graph = RecitationAssigner.assignment_graph 4, [2, 4], [10, 12, 13], [
      {:athena => 'ben',
       :conflicts => {102 => true, 124 => true, 131 => true}},
      {:athena => 'genius',
       :conflicts => {130 => true, 132 => true, 140 => true, 142 => true}},
    ]
    
    assert_equal Set.new([:sink, :source, 'ben', 'genius',
                          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]),
                 Set.new(graph[:vertices]), 'Vertices'

    e = graph[:edges]
    assert_equal Set.new(graph[:vertices]), Set.new(e.keys),
                 'Edges correspond to vertices in the graph'
    assert_equal({'ben' => 0, 'genius' => 0}, e[:source], 'Source edges')
    (0...12).to_a.each do |v|
      assert_equal({:sink => 0}, e[v], "Edge from #{v} to sink")
    end
    assert_equal({8 => 0, 9 => 0, 10 => 0, 11 => 0}, e['ben'],
                 'Ben can only do 13:00')
    assert_equal({0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0,
                  7 => 0}, e['genius'],
                 'Dexter can do 10:00 and 12:00')
  end
  
  def test_assignment
    matching = RecitationAssigner.assignment 1, [2, 4], [10, 12, 13], [
      {:athena => 'ben',
       :conflicts => {102 => true, 124 => true, 131 => true}},
      {:athena => 'genius',
       :conflicts => {120 => true, 122 => true, 140 => true, 142 => true}},
    ]
    
    assert_equal({'ben' => 13, 'genius' => 10}, matching)
  end
  
  def test_reverted_assignment
    assert_equal({10 => ['a', 'e'], 11 => ['b', 'c'], 12 => ['d']},
                 RecitationAssigner.reverted_assignment('a' => 10, 'b' => 11,
                                                        'c' => 11, 'd' => 12,
                                                        'e' => 10))    
  end
end
