module RegistrationsHelper
  def recitation_select(registration)
    is_selected = registration.recitation_section.nil? ? nil : registration.recitation_section.serial()

		collection_select :registration, :recitation_section_id,
        RecitationSection.all, :id, :recitation_name,
        { prompt: 'Select Recitation',
          selected: is_selected },
          { data: { remote: true,
                    url: restricted_registration_url(registration),
                    method: :patch },
            id: "recitation_section_#{registration.id}" }
  end
end
