module RecitationSectionsHelper
  def recitation_leader_label(recitation)
    leader_name = recitation.leader ? recitation.leader.name : '(no leader)'
  end

  def recitation_name_label(recitation)
    "#{recitation.location} #{recitation_leader_label recitation}"
  end

  def display_name_for_recitation_section(recitation_section, format = :short)
    return 'no assignment' unless recitation_section
    "R#{'%02d' % recitation_section.serial} - #{recitation_section.location} #{recitation_section.leader.display_name_for}"
  end
end
