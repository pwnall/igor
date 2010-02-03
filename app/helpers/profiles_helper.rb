module ProfilesHelper
  # Returns a good guess for a student's university based on their Athena info.
  #
  # The Athena information is supplied by the mit_stalker gem. The return value
  # is a string with the full name of the school.
  def guess_university_from_athena(athena_info)
    # Only MIT students have academic information in WebSIS.
    if athena_info[:department] || athena_info[:school] || athena_info[:year]
      return 'Massachusetts Institute of Technology'  
    end
    
    # Wellesley College studens usually live at Wellesley. Attempt to generalize
    # into keyword scanning.
    keywords = [
      ['Wellesley College', [/Wellesley/]],
      ['Harvard University', [/Harvard/]]  # Can add streets near Harvard etc.
    ]    
    scores = {}
    keywords.each do |school, patterns|
      scores[school] = 0
      patterns.each do |pattern|
        athena_info.each do |key, value|
          scores[school] += 1 if pattern =~ value
        end
      end
    end
    max_score = scores.to_a.sort_by(&:last).last
    max_score.last == 0 ? '' : max_score.first
  end
end
