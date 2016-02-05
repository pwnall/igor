module RecitationSectionsHelper
  def recitation_leader_label(recitation)
    leader_name = recitation.leader ? recitation.leader.name : '(no leader)'
  end

  def recitation_name_label(recitation)
    "#{recitation.location} #{recitation_leader_label recitation}"
  end

  def display_name_for_recitation_section(recitation, format = :short)
    return 'Unassigned' unless recitation
    "R#{'%02d' % recitation.serial} - #{recitation.location} #{recitation.leader.display_name_for}"
  end
end
