module RegistrationsHelper
  def recitation_select(registration)
    isSelected = registration.recitation_section.nil? ? nil : registration.recitation_section.serial()

		collection_select :recitation_section, :serial,
				      RecitationSection.all, :serial, :recitation_name,
				      { :prompt => 'Select Recitation',
					      :selected => isSelected }, 					    
              :data => { :remote => true,
						             :url => url_for(registration),
						             :method => :put } %>
  end
end
