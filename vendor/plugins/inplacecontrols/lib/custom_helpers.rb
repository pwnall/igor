class Object
	def proper_case
		self.to_s.humanize.split(/\s/).map { |e| e.capitalize }.join(" ")
	end
end
module CustomHelpers
	STATES = [ 	
		['Select a State', 'None'],
		['Alabama', 'AL'], 
		['Alaska', 'AK'],
		['Arizona', 'AZ'],
		['Arkansas', 'AR'], 
		['California', 'CA'], 
		['Colorado', 'CO'], 
		['Connecticut', 'CT'], 
		['Delaware', 'DE'], 
		['District Of Columbia', 'DC'], 
		['Florida', 'FL'],
		['Georgia', 'GA'],
		['Hawaii', 'HI'], 
		['Idaho', 'ID'], 
		['Illinois', 'IL'], 
		['Indiana', 'IN'], 
		['Iowa', 'IA'], 
		['Kansas', 'KS'], 
		['Kentucky', 'KY'], 
		['Louisiana', 'LA'], 
		['Maine', 'ME'], 
		['Maryland', 'MD'], 
		['Massachusetts', 'MA'], 
		['Michigan', 'MI'], 
		['Minnesota', 'MN'],
		['Mississippi', 'MS'], 
		['Missouri', 'MO'], 
		['Montana', 'MT'], 
		['Nebraska', 'NE'], 
		['Nevada', 'NV'], 
		['New Hampshire', 'NH'], 
		['New Jersey', 'NJ'], 
		['New Mexico', 'NM'], 
		['New York', 'NY'], 
		['North Carolina', 'NC'], 
		['North Dakota', 'ND'], 
		['Ohio', 'OH'], 
		['Oklahoma', 'OK'], 
		['Oregon', 'OR'], 
		['Pennsylvania', 'PA'], 
		['Rhode Island', 'RI'], 
		['South Carolina', 'SC'], 
		['South Dakota', 'SD'], 
		['Tennessee', 'TN'], 
		['Texas', 'TX'], 
		['Utah', 'UT'], 
		['Vermont', 'VT'], 
		['Virginia', 'VA'], 
		['Washington', 'WA'], 
		['West Virginia', 'WV'], 
		['Wisconsin', 'WI'], 
		['Wyoming', 'WY']]


		def inplace_error_div
			content_tag(:div, "", :id => "error_messages")
		end

		def invisible_loader(message = nil, div_id = "loader", class_name = "loader", color = "regular")
			ret = ""
			ret << "<div id=\"#{div_id}\" style=\"display:none\" class=\"#{class_name}\">"
			ret << image_tag("spinner.gif") if color == "regular"
			ret << image_tag("spinner_white.gif") if color == "white"
			ret << image_tag("spinner_update_list.gif") if color == "update_list"

			ret << "&nbsp;&nbsp;<span>#{message.to_s}</span>"
			ret << "</div>"
		end

		def text_field_with_label(object_name, method, options = {})
			set_class_name(options, "text_field")
			ret = create_label_field(object_name, method, options)
			ret << text_field( object_name, method, options)
			ret << add_break_to_form(options)
		end

		def select_field_with_label(object_name, method, choices, options = {}, html_options = {})
			set_class_name(options, "select")
			ret = create_label_field(object_name, method, options)
			ret << select( object_name, method, choices, options, html_options)
			ret << add_break_to_form(options)

		end

		def textarea_field_with_label(object_name, method, options = {})
			set_class_name(options, "textarea")
			ret = create_label_field(object_name, method, options)
			ret << text_area( object_name, method, options)
			ret << add_break_to_form(options)

		end

		def checkbox_field_with_label(object_name, method, options = {})
			set_class_name(options, "checkbox")
			rad_options = options.dup
			rad_options.delete(:break_after_label)
			rad_options.delete(:human_name)

			ret = check_box(object_name, method, rad_options)
			ret << create_label_field(object_name, method, options)
			ret << add_break_to_form(options)

		end

		def radio_button_with_label(object_name, method, value, options = {}, html_options = {})	
			rad_options = options.dup
			rad_options.delete(:br)
			rad_options[:class] = "radio_button"
			ret = radio_button( object_name, method, value, rad_options)
			options[:human_name] = options[:human_name] || value
			options[:radio_label] = true
			options[:radio_value] = value
			ret << create_label_field(object_name, method, options)
			ret << add_break_to_form(options)
			# rescue Exception => e
			# 	  raise ret.inspect + "\n\n" +  e.to_s + "\n\n\n\n\n\n" + e.backtrace.join("\n")
		end

		def set_class_name(options, type)
			options.merge!({:class => "input_#{type}" })
		end

		def create_label_field(object_name, method, options = {})
			human_name = options[:human_name] || method.proper_case.gsub(/url/i, "URL")
			id_string = "#{object_name.to_s.downcase}_#{method.to_s.downcase}"
			id_string = id_string + "_#{options[:radio_value].rubify}" if options[:radio_label]
			label_id = id_string + "_" + "label"
			ret = "<label for=\"#{id_string}\" id=\"#{label_id}\">#{human_name}:"
			ret << "*" if options[:required] == true
			ret << " </label>"
			ret << "<br />" if options[:break_after_label]
			ret
		end

		def add_break_to_form(options)
			unless options[:br] == false && !options[:br].nil?
				ret = "<br />"
			end
			ret || ""
		end

		def state_select(object, method)
			select(object, method, STATES)

		end

	end