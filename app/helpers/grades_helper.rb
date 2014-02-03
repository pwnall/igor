module GradesHelper
  # Returns true if the user has comments for any problem in a certain assignment.
  def has_comments(metrics)
    metrics.any? { |metric, grade| has_comment grade }
  end 

  # Returns true if user has comment for a particular grade.
  def has_comment(grade)
    begin
      x = !grade.comment[:comment].blank?
    rescue
      x = false
    ensure
      return x
    end
  end
end
