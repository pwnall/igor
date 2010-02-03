#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'config', 'environment.rb')

module RecitationAssigner
  # The raw conflict information obtained directly from the API.
  def self.raw_conflicts_info
    Net::HTTP.get URI.parse('http://alg.csail.mit.edu/api/conflict_info.json')
  end
  
  # The conflict information.
  #
  # Returns an array with an element for each student to be assigned to a
  # section. The array has the following keys:
  #     :athena:: the user's Athena ID
  #     :conflicts:: a hash associating conflict times with conflict information
  #
  # Example:
  #   {:athena => 'genius', :conflicts => {120 => {:....} } }
  def self.conflicts_info    
    students = JSON.parse raw_conflicts_info
    students['info'].map do |student|
      {
        :conflicts => student['conflicts'].reject { |c|
          c['class'].strip == Course.main.number || c['class'] == 'free' }.
                                           index_by { |c| c['timeslot'] },
        :athena => student['athena']
      }
    end
  end
  
  # Finds an optimal assignment of students to recitation sections.
  #
  # Args:
  #   section_size:: maximum number of students in a section
  #   section_days:: array with weekdays when the sections should run;
  #                  example: [2, 4] means Wednesday + Friday
  #   section_times:: array with the section times; example: [10, 11, 13, 14]
  #   students:: array with student information; each element should match the
  #              format produced by conflicts_info
  #
  # Returns a hash associating each student that was matched with a recitation
  # time.
  def self.assignment(section_size, section_days, section_times, students)
    graph = assignment_graph section_size, section_days, section_times, students
    matching = best_matching! graph
    
    Hash[*(matching.map { |student, seat|
      [student, section_times[seat / section_size]]
    }.flatten)]
  end
  
  # Builds a bipartite graph for matching students to recitation sections.
  def self.assignment_graph(section_size, section_days, section_times, students)
    seats = (0...(section_times.length * section_size)).to_a    
    athenas = students.map { |c| c[:athena] }
    vertices = athenas + seats + [:source, :sink]
    
    edges = Hash[*(vertices.map { |v| [v, {}] }.flatten)]
    athenas.each { |athena| edges[:source][athena] = 0 }
    seats.each { |seat| edges[seat][:sink] = 0 }
    students.each do |student|
      section_times.each_with_index do |time, time_index|
        has_conflicts = section_days.any? do |day|
          student[:conflicts].has_key? day + time * 10
        end
        next if has_conflicts
        
        0.upto(section_size - 1) do |section_seat|
          edges[student[:athena]][section_seat + time_index * section_size] = 0
        end
      end
    end
    { :vertices => vertices, :edges => edges }
  end
  
  # Finds a maximal matching in a bipartite graph. Mutates the graph.
  #
  # Returns a hash representing the matching.
  def self.best_matching!(graph, source = :source, sink = :sink)
    loop do
      path = augmenting_path graph
      break unless path
      augment_flow_graph! graph, path
    end    
    matching_in_graph graph, source, sink
  end
  
  # Finds an augmenting path in a flow graph.
  #
  # Returns the path from source to sink, as an array of edge arrays, for
  # example [[:source, 'a'], ['a', 'c'], ['c', :sink]]
  def self.augmenting_path(graph, source = :source, sink = :sink)
    # TODO(costan): replace this with Bellman-Ford to support min-cost matching.
    
    # Breadth-first search.
    parents = { source => true }
    queue = [source]
    until queue.empty?
      current_vertex = queue.shift
      break if current_vertex == sink
      (graph[:edges][current_vertex] || {}).each do |new_vertex, edge|
        next if parents[new_vertex]
        parents[new_vertex] = current_vertex
        queue << new_vertex
      end
    end
    return nil unless parents[sink]
    
    # Reconstruct the path.
    path = []
    current_vertex = sink
    until current_vertex == source
      path << [parents[current_vertex], current_vertex]
      current_vertex = parents[current_vertex]
    end
    path.reverse!
  end 

  # Augments a flow graph along a path.
  def self.augment_flow_graph!(graph, path)
    # Turn normal edges into residual edges and viceversa.    
    edges = graph[:edges]
    path.each do |u, v|
      edges[v] ||= {}
      edges[v][u] = -edges[u][v]
      edges[u].delete v
    end
  end
  
  # The matching currently found in a matching graph.
  def self.matching_in_graph(graph, source = :source, sink = :sink)
    Hash[*((graph[:edges][sink] || {}).keys.map { |matched_vertex|
      [graph[:edges][matched_vertex].keys.first, matched_vertex]
    }.flatten)]
  end
  
  # The reverse of a student -> section assignment.
  def self.reverted_assignment(matching)
    reverted = {}
    matching.each { |k, v| reverted[v] ||= []; reverted[v] << k }
    reverted
  end
end


def nice_times(section_size, days, students)
  times = [10, 11, 12, 13, 14, 15]
  mm_length = 0
  mm_alts = []
  mm = nil

  matching = RecitationAssigner.assignment section_size, days, times, students
  reverted_matching = RecitationAssigner.reverted_assignment matching
  
  puts "Conflicts: #{students.length - matching.length}"
  reverted_matching.each do |k, v|
    puts "\nSection: #{k} (#{v.length} students)"
    puts v.map { |a| "#{a}@mit.edu" }.join(", ")
  end
  puts "\nScrewed: "
  puts((students.map { |s| s[:athena] } - matching.keys).
       map { |a| "#{a}@mit.edu" }.join(", "))
end

def sucky_times(section_size, days, students)
  mm_length = 0
  mm_times = nil
  mm = nil
  mm_alts = []
  10.upto(12) do |t1|
    t1.upto(13) do |t2|
      t2.upto(14) do |t3|
        t3.upto(15) do |t4|
          m = RecitationAssigner.assignment section_size, days,
                                            [t1, t2, t3, t4], students
          if m.length > mm_length
            mm_length = m.length
            mm = m
            mm_times = [t1, t3, t2, t4]
            mm_alts = []
          elsif m.length == mm.length
            mm_alts << [t1, t3, t2, t4]
          end
        end
      end
    end
  end  

  pp mm_length
  pp mm_times
  pp mm
  pp(students.map { |s| s[:athena] } - mm.keys)
  pp mm_alts
end

if $0 == __FILE__
  section_size = 26
  days = [2, 4]
  students = RecitationAssigner.conflicts_info
  nice_times section_size, days, students
#  sucky_times section_size, days, students
end
