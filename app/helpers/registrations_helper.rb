module RegistrationsHelper
  # A selection of recitations you can assign to a registered student.
  def recitation_select_tag(registration)
    return unless registration
    name = 'registration[recitation_section_id]'
    recitation_options = registration.course.recitation_sections.map do |rs|
      [recitation_name_label(rs), rs.id]
    end
    selected = registration.recitation_section_id
    select_tag name, options_for_select(recitation_options, selected),
        prompt: 'Select a section...'
  end
end
