module RecitationSectionsHelper
  def display_name_for_recitation_section(recitation_section, format = :short)
    return 'no assignment' unless recitation_section
    "R#{'%02d' % recitation_section.serial} - #{recitation_section.time}, #{recitation_section.location} #{display_name_for_user recitation_section.leader, :really_short}"
  end
end
