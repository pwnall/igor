# InPlaceControls - Do in-place-style editors with other form controls
module InPlaceControls

  module ControllerMethods #:nodoc:
    # needed for fields that can return false, which causes it to search for a template
    def in_place_edit_for_with_boolean(object, attribute) 
       define_method("set_#{object}_#{attribute}") do
             @item = object.to_s.camelize.constantize.find(params[:id])
             @item.update_attributes(attribute => params[:value])
             render :text => @item.send(attribute).to_s
       end
    end
    alias_method :in_place_edit_for_boolean, :in_place_edit_for_with_boolean
  end
  
  # These methods are mixed into the view as helpers.
  # Common options for the helpers:
  #   :action - the action to submit the change to
  #   :saving_text - text to show while the request is processing.  Default is "Saving..."
  #   :object - the object to create the control for, if other than an instance variable. (Useful for iterations.)
  # Any other options will be passed on to the HTML control(s).
  module HelperMethods
    # Creates "active" radio button controls that submit any changes to the server
    # using an <tt>in_place_edit</tt>-style action.
    # Options:
    #   :choices - (required) An array of choices to be presented as radio buttons, in a form similar to "options_for_select"
    # Examples:
    #   <%= in_place_radio_buttons :post, :can_comment, :choices => ["none", "registered", "everyone"] %>
    #   <%= in_place_radio_buttons :post, :published, :choices => [[true, "Yes"],[false, "No"]] %>
    def in_place_radio_buttons(object, method, options = {})
      InPlaceControls::HelperMethods::InPlaceControl.new(object, method, self, options).to_radios
    end

    # Creates an "active" select box control that submits any changes to the server
    # using an <tt>in_place_edit</tt>-style action.
    # Options:
    #   :choices - (required) An array of choices (see in_place_radio_buttons) or the result of calling "options_for_select"
    # By default the value of the object's attribute will be selected, or blank.
    # Examples:
    #   <%= in_place_select :post, :category, :choices => ["article", "blog", "announcement"] %>
    #   <%= in_place_select :address, :country, :choices => country_options_for_select %>
    def in_place_select(object, method, options = {})
      InPlaceControls::HelperMethods::InPlaceControl.new(object, method, self, options).to_select
    end

    # Creates an "active" check box control that submits any changes to the server
    # using an <tt>in_place_edit</tt>-style action.
    # Options:
    #   :checked - (required) The value the field should have when checked
    #   :unchecked - (required) The value the field should have when unchecked
    # Examples:
    #   <%= in_place_checkbox :user, :is_admin, :checked => true, :unchecked => false %>
    #   <%= in_place_checkbox :user, :verified, :checked => 1, :unchecked => 0 %>
    def in_place_checkbox(object, method, options = {})
      InPlaceControls::HelperMethods::InPlaceControl.new(object, method, self, options).to_checkbox
    end
    
    class InPlaceControl #:nodoc:     
      attr_accessor :options      
      
      def initialize(object, method, template, opts={})
        @options = opts.symbolize_keys
        @object_name = object.to_s
        @object = @options[:object] || template.instance_variable_get("@#{object}")
        @method_name = method.to_s
        @value = @object.send(method)
        @template = template
      end
      
      def to_checkbox
        raise ArgumentError, "Missing checked value! Specify options[:checked]" if @options[:checked].nil?
        raise ArgumentError, "Missing unchecked value! Specify options[:unchecked]" if @options[:unchecked].nil?
        
        options[:onclick] = onchange_function(:checkbox)
        output = @template.tag(:span, {:id => container_id(:checkbox)}, true)
        output.safe_concat(@template.check_box_tag(field_id, @options[:checked], @options[:checked]==@value, cleanoptions))
        output.safe_concat("</span>")
        output.safe_concat(@template.tag(:span, {:id => saving_id, :style => "display:none;"}, true))
        output.concat(saving_text)
        output.safe_concat("</span>")
        output.safe_concat(update_function(:checkbox))
      end

      def to_radios
        raise ArgumentError, "Missing choices for radios" if options[:choices].nil?
        raise ArgumentError, "options[:choices] must be an array" if !options[:choices].is_a?(Array)
        options[:onchange] = onchange_function(:radio)
        output = @template.tag(:span, {:id => container_id(:radio)}, true)
        options[:choices].each do |choice|
          if choice.is_a?(Array)
            v, label = choice[0].to_s, choice[1].to_s
          else
            v, label = choice.to_s, choice.to_s.humanize
          end
          output.safe_concat(@template.radio_button_tag(field_id, v, (@value.to_s == v.to_s), cleanoptions))
          output.safe_concat(label + " ")
        end
        output.safe_concat("</span>")
        output.safe_concat(@template.tag(:span, {:id => saving_id, :style => "display:none;"}, true))
        output.concat(saving_text)
        output.safe_concat("</span>")
        output.safe_concat(update_function(:radio))
      end
      
      def to_select
        raise ArgumentError, "Missing choices for select! Specify options[:choices]" if options[:choices].nil?
        options[:onchange] = onchange_function(:select)
        output = @template.tag(:span, {:id => container_id(:select)}, true)
        if options[:choices].is_a?(Array)
          options[:choices] = @template.options_for_select(options[:choices], @value)
        end
        output.safe_concat(@template.select_tag(field_id, options[:choices], cleanoptions))
        output.safe_concat("</span>")
        output.safe_concat(@template.tag(:span, {:id => saving_id, :style => "display:none;"}, true))
        output.concat(saving_text)
        output.safe_concat("</span>")
        output.safe_concat(update_function(:select))
      end
                
      private
      def cleanoptions
        @options.dup.delete_if { |key, value| [:action, :checked, :unchecked, :choices, :saving_text, :id].include?(key)}
      end
      
      def field_id
        "#{@object_name}_#{@object.id}_#{@method_name}"
      end
      
      def saving_id
        "#{field_id}_saving"
      end
      
      def url_action
        @options[:action] || "set_#{@object_name}_#{@method_name}"
      end
      
      def saving_text
        @options[:saving_text] || "Saving..."
      end
      
      def onchange_function(type)
        case type
          when :checkbox
            "update_#{field_id}((this.checked)? '#{@options[:checked]}' : '#{@options[:unchecked]}');"
          when :radio, :select
            "update_#{field_id}($('#{field_id}').value);"
          else
            ""
        end
      end
      
      def container_id(type)
        case type
          when :checkbox
            "checkbox_for_#{field_id}"
          when :radio
            "radios_for_#{field_id}"
          when :select
            "select_for_#{field_id}"
          else
            ""
        end
      end
    
      def update_function(type)
        js =  "window.update_#{field_id} = function(value)\n"
        js << "{\n"
        js << " $('#{container_id(type)}').hide(); $('#{saving_id}').show(); \n"
        js << " new Ajax.Request(\n"
        js << "'" + (@options[:url] || @template.url_for(:action => url_action, :id => @object.id)) + "', \n"
        js << "{ parameters: 'authenticity_token=#{@template.form_authenticity_token}&value=' + encodeURI(value),\n"
        js << "  onComplete: function(response) {\n"
        js << "      $('#{field_id}').value = response.responseText;\n"
        js << "      $('#{saving_id}').hide(); $('#{container_id(type)}').show();\n"    
        js << "      new Effect.Highlight('#{container_id(type)}');\n"
        js << " }\n"
        js << " } );\n"
        js << " return false; \n"
        js << " }\n"
        @template.javascript_tag(js)
      end
    end
  end
end

# Hook code
ActionController::Base.class_eval do #:nodoc:
  extend InPlaceControls::ControllerMethods
  class << self
    alias_method_chain :in_place_edit_for, :boolean
  end
end

ActionView::Base.class_eval do #:nodoc:
  include InPlaceControls::HelperMethods
end
