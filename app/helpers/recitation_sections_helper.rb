module RecitationSectionsHelper

  def recitation_name_label(recitation)
    leader_name = recitation.leader ? recitation.leader.name : '(no leader)'
    "#{recitation.location} #{leader_name}"
  end

  def display_name_for_recitation_section(recitation_section, format = :short)
    return 'no assignment' unless recitation_section
    "R#{'%02d' % recitation_section.serial} - #{recitation_section.location} #{recitation_section.leader.display_name_for}"
  end

  def recitation_leaders
    Course.main.staff
  end
end
