module GradesHelper
  # returns true if the user has comments for any problem in a certain assignment 
  def has_comments(metrics)
    mapped = metrics.map {
      |metric, grade| 
      grade and grade.comments and grade.comments != ""
      }
    reduced = mapped.inject {
      |state, obj|
      state or obj
      }
    return reduced
    end 
end
