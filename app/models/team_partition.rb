# A partitioning of students into teams.
class TeamPartition < ActiveRecord::Base
  # True if this partitioning is visible to the students.
  validates_inclusion_of :published, :in => [true, false], :allow_nil => false
  
  # True if this partitioning was automatically generated. If false, the
  # students are allowed to pair up via a Web UI.
  validates_inclusion_of :automated, :in => [true, false], :allow_nil => false  
end
