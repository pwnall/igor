module RegistrationsHelper
  def recitation_select(registration)
    is_selected = registration.recitation_section.nil? ? nil : registration.recitation_section.serial()

		collection_select :recitation_section, :serial,
                      RecitationSection.all, :serial, :recitation_name,
                      { prompt: 'Select Recitation',
                        selected: is_selected }, 					    
                        data: { remote: true,
                                url: url_for(registration),
                                method: :put }
  end
end
