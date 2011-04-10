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
    
    # Wellesley College studens usually live at Wellesley.
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
  
  # Intended for use in a select field for the year on a user profile.
  def profile_year_options(profile)
    options = [
      ['Freshman (1)', '1'],
      ['Sophomore (2)', '2'],
      ['Junior (3)', '3'],
      ['Senior (4)', '4'],
      ['Graduate (G)', 'G']
    ]
    # Make the selected option stick in FireFox by putting it first.   
    yr_index =
       (0...(options.length)).find { |i| options[i][1] == profile.year } || 0
    options[yr_index...(options.length)] + options[0...yr_index]
  end
  
  # Intended for use in a select field for the recitation on a user profile.
  def profile_recitation_section_options(profile)
    options = RecitationSection.all.map do |s|
      [display_name_for_recitation_section(s), s.id]
    end
    # Make the selected option stick in FireFox by putting it first.   
    rs_index = (0...(options.length)).find do |i|
      options[i][1] == profile.recitation_section_id
    end
    rs_index ||= 0
    options[rs_index...(options.length)] + options[0...rs_index]
  end  
end
