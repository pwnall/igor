# Generates the markup expected by Foundation.
class FoundationFormBuilder < ActionView::Helpers::FormBuilder
  include IconsHelper

  def initialize(*args)
    super
    @inside_destroy_record_field = false
    @inside_input_group = false
    @inside_row = false
    @inside_switch_paddle = false
  end

  # Generates wrappers for most field helpers.
  (field_helpers - [:label, :check_box, :radio_button, :fields_for,
                    :hidden_field]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(attr, options = {})
        input_field_wrapper attr, options do |super_options|
          super attr, super_options
        end
      end
    RUBY_EVAL
  end

  # @private
  # check_box is special-cased because of its arguments.
  def check_box(attr, options = {}, checked_value = "1", unchecked_value = "0")
    if @inside_destroy_record_field || @inside_switch_paddle
      super
    else
      check_box_field attr, options do
        super
      end
    end
  end

  # @private
  # radio_button is special-cased because of its arguments.
  def radio_button(attr, tag_value, options = {})
    input_field_wrapper attr, options do
      super
    end
  end

  # @private
  # select is special-cased because of its arguments.
  def select(attr, choices = nil, options = {}, html_options = {})
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  # @private
  # collection_select is special-cased because of its arguments.
  def collection_select(attr, collection, value_method, text_method, options = {}, html_options = {})
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  # @private
  # grouped_collection_select is special-cased because of its arguments.
  def grouped_collection_select(attr, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  # @private
  # time_zone_select is special-cased because of its arguments.
  def time_zone_select(attr, priority_zones = nil, options = {}, html_options = {})
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  def time_select(attr, options = {}, html_options = {})
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  # @private
  # collection_radio_buttons is special-cased because of its arguments.
  def collection_radio_buttons(attr, collection, value_method, text_method, options = {}, html_options = {}, &block)
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  # @private
  # collection_check_boxes is special-cased because of its arguments.
  def collection_check_boxes(attr, collection, value_method, text_method, options = {}, html_options = {}, &block)
    input_field_wrapper attr, options, html_options do
      super
    end
  end

  # A button, styled appropriately for any surrounding Foundation components.
  #
  # Inline buttons within a Foundation input group have additional classes.
  def button(value = nil, options = {}, &block)
    value, options = nil, value if value.is_a?(Hash)
    if @inside_input_group
      options[:class] ||= ''
      options[:class] << ' input-group-button'
    end
    super
  end

  # Wrap the yielded form input field in the appropriate Foundation-styled HTML.
  #
  # @param [Symbol] attr the attribute accessed by the yielded form field
  # @param [Hash] options the options passed to the field helper
  # @option options [String] :label the text of the label for an <input> or
  #   <select> tag
  # @param [Hash] html_options additional options passed to field helpers that
  #   specify the HTML :class attribute in a second set of options
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   <input> or <select> tag
  # @return [ActiveSupport::SafeBuffer] sanitized HTML markup for the entire
  #   Foundation-styled field, including the <input>/<select> tag, any
  #   applicable validation errors, any specified labels, all encased in the
  #   appropriate wrapper
  def input_field_wrapper(attr, options = {}, html_options = nil, &block)
    label_text = options.delete :label
    @label_html = label_html_for attr, label_text, class: 'text-right middle'
    @input_html = input_html_for attr, options, html_options, &block
    @help_html = help_html_for attr, options
    @errors_html = errors_html_for attr

    if @inside_input_group
      @input_html
    elsif @label_html
      labeled_input = columnize @label_html, input_with_errors
      @inside_row ? labeled_input : row { labeled_input }
    else
      input_with_errors
    end
  end
  private :input_field_wrapper

  # Wrap a given label and input in our standard 3/6 column layout.
  #
  # The field's label occupies the leftmost 3 columns, and the <input>/<select>
  # tag(s) occupy the next 6 columns.
  #
  # @param [ActiveSupport::SafeBuffer] label_html the field's label
  # @param [ActiveSupport::SafeBuffer] input_html the <input>/<select> tag(s)
  # @return [ActiveSupport::SafeBuffer] the label and input tag(s) wrapped in
  #   Foundation columns
  def columnize(label_html, input_html)
    @template.content_tag(:div, label_html, class: 'small-3 columns') +
    @template.content_tag(:div, input_html, class: 'small-6 columns')
  end
  private :columnize

  # A Foundation-styled <input>/<select> tag + help text + validation errors.
  #
  # @return [ActiveSupport::SafeBuffer] sanitized HTML markup for the <input>/
  #   <select> tag, any help text, and any applicable validation error messages
  def input_with_errors
    @input_html + @help_html + @errors_html
  end
  private :input_with_errors

  # A Foundation-styled <label> tag for a form field.
  #
  # @param [Symbol] attr the attribute being labeled; nil, if the label is for
  #   a set of attributes, rather than a single attribute
  # @param [String] text the label's text
  # @param [Hash] options the options passed to the label helper
  # @yieldreturn [ActiveSupport::SafeBuffer] the label's text; passed to the
  #   parent label helper method
  # @return [ActiveSupport::SafeBuffer?] sanitized HTML markup for the <label>
  #   tag; nil, if no text was provided
  def label_html_for(attr, text, options = {}, &block)
    return nil unless text
    return @template.content_tag :label, text, options if attr.nil?
    options[:class] ||= ''
    options[:class] << ' is-invalid-label' if object.errors[attr].any?
    label attr, text, options, &block
  end
  private :label_html_for

  # A Foundation-styled <input> or <select> tag for a form field.
  #
  # @param [Symbol] attr the attribute accessed by the <input>/<select> tag
  # @param [Hash] options the options passed to the field helper
  # @option options [String] :class the HTML classes to apply to the <input> tag
  # @param [Hash] html_options additional options passed to field helpers that
  #   specify the HTML :class attribute in a second set of options
  # @yield [options, html_options] Passes the options and/or html_options hashes
  #   to the field helper to render the <input>/<select> tag.
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   <input>/<select> tag
  def input_html_for(attr, options = {}, html_options = nil)
    class_option = html_options || options
    class_option[:class] ||= ''
    if attr && object.errors[attr].any?
      class_option[:class] << ' is-invalid-input'
    end
    options[:class] << ' input-group-field' if @inside_input_group

    args = html_options ? [options, html_options] : [options]
    yield *args
  end
  private :input_html_for

  # A Foundation-styled help text that appears beneath an <input>/<select> tag.
  #
  # (http://foundation.zurb.com/sites/docs/forms.html#help-text)
  #
  # @param [Symbol] attr the attribute that this text describes
  # @param [Hash] options the options passed to the field helper
  # @option options [String] :help_text the text description
  # @return [ActiveSupport::SafeBuffer] a <p> tag containing the help text
  def help_html_for(attr, options)
    help_text = options.delete :help_text
    help_text ? @template.content_tag(:p, help_text, class: 'help-text') : ''
  end
  private :help_html_for

  # Foundation-styled HTML for an attribute's validation errors.
  #
  # Subclasses might want to override this.
  #
  # @param [Symbol] attr the attribute whose input values may have errors; nil,
  #   if the field encompasses multiple attributes
  # @return [ActiveSupport::SafeBuffer] a <span> tag containing the given
  #   attribute's validation error messages; an empty string if the element has
  #   no errors
  def errors_html_for(attr)
    return '' unless object.respond_to? :errors
    return '' if attr.nil? || object.errors[attr].empty?

    @template.content_tag :span, class: 'form-error is-visible' do
      # For some reason, :get breaks controller tests, so use :messages.
      messages = object.errors.messages[attr] || []
      messages.join ', '
    end
  end
  private :errors_html_for

  # Wrap the block in a Foundation 'row' wrapper.
  #
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   contents of the form field
  # @return [ActiveSupport::SafeBuffer] a full form field occupying one row
  def row(&block)
    @inside_row = true
    inner_html = @template.capture &block
    @inside_row = false

    @template.content_tag :div, inner_html, class: 'row'
  end

  # A form field with one label for many <input> tags.
  #
  # @param [String] label the text of the shared label
  # @param [Array] fields the parameters for building the <input> tags; each
  #   element is an array of arguments for building one <input> tag, where the
  #   first argument is the field helper method (e.g. :check_box) and the rest
  #   are the arguments passed to that method
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   <input>/<select> tags that should appear to the right of the label
  # @return [ActiveSupport::SafeBuffer] a full standard input field, where
  #   multiple <input> tags are grouped with a shared label
  def input_field_set(label: '', &block)
    label_html = label_html_for nil, label, class: 'text-right middle'
    @inside_row = true
    fields_html = @template.capture &block
    @inside_row = false

    row { columnize label_html, fields_html }
  end

  # The inline label of a Foundation input group <input> tag.
  #
  # @param [String] text the text of the inline label
  # @return [ActiveSupport::SafeBuffer] a <span>, formatted as a Foundation
  #   input group inline label
  def inline_label(text)
    @template.content_tag :span, text, class: 'input-group-label'
  end

  # A form field whose <input> tag is styled as a Foundation input group.
  #
  # (http://foundation.zurb.com/sites/docs/forms.html#inline-labels-and-buttons)
  #
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   <input> tag, and the inline label or button
  # @return [ActiveSupport::SafeBuffer] a full standard input field, where the
  #   <input> tag is styled as a Foundation input group
  def input_group(&block)
    @inside_input_group = true
    inner_html = @template.capture &block
    group_html = @template.content_tag(:div, inner_html, class: 'input-group') +
        @errors_html
    output_html = @label_html ? columnize(@label_html, group_html) : group_html
    @inside_input_group = false

    row { output_html }
  end

  # Formatted HTML for an <input> field of type "checkbox".
  #
  # @param [Symbol] attr the attribute whose value this check box toggles
  # @param [Hash] options the options passed to the field helper
  # @option options [String] :label the label text for this check box
  # @return [ActiveSupport::SafeBuffer] a labeled check box field
  def check_box_field(attr, options = {}, &block)
    label_text = options.delete :label
    input_html = input_html_for attr, options, &block
    errors_html = errors_html_for attr
    label_html_for attr, class: 'check-box-label' do
      @template.content_tag(:span, input_html, class: 'check-box-wrapper') +
      @template.content_tag(:span, label_text, class: 'label-text') +
      errors_html
    end
  end
  private :check_box_field

  # Formatted HTML for an <input> tag that marks a record for destruction.
  #
  # @param [Symbol] attr the attribute that identifies whether a record should
  #   be destroyed, typically :_destroy for destroying associated records
  # @param [Hash] options the options passed to the field helper
  # @yield [options] Calls the block to render the <input> tag
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   <input> tag
  # @return [ActiveSupport::SafeBuffer] an <input> tag, followed by an icon and
  #   text reflective of the field's destructive nature, all of which occupy 3
  #   columns
  def destroy_record_field(attr, options = {})
    @inside_destroy_record_field = true
    output_html = @template.content_tag :span, class: 'destroy' do
      label attr, class: 'middle' do
        check_box(attr, options) + destroy_icon_tag + ' Remove'
      end
    end
    @inside_destroy_record_field = false

    output_html
  end

  # Formatted HTML for a Foundation switch paddle.
  #
  # @param [Symbol] attr the attribute whose value gets toggled
  # @param [Hash] options the options passed to the check_box helper
  # @return [ActiveSupport::SafeBuffer] sanitized HTML for a switch paddle
  def switch_paddle(attr, options = {})
    @inside_switch_paddle = true
    output_html = check_box attr, options
    @inside_switch_paddle = false

    output_html
  end

  # HTML data attributes to apply to the <input> tag of an optional field.
  #
  # @param [String] pwnfx_scope the value assigned to the data-pwnfx-scope
  #   attribute, and used to derive the data-pwnfx-disable-positive attribute
  # @return [Hash] the pwnfx data attributes for optional <input>/<select> tags
  def optional_input_data(pwnfx_scope)
    pwnfx_tag_id = pwnfx_scope + '_field'
    { pwnfx_scope: pwnfx_scope, pwnfx_disable_positive: pwnfx_tag_id }
  end

  # HTML data attributes to apply to the disabling switch of an optional field.
  #
  # @param [String] pwnfx_scope the value assigned to the
  #   data-pwnfx-disable-scope attribute, and used to derive the
  #   data-pwnfx-disable attribute
  # @return [Hash] the pwnfx data attributes for the <input> tag that triggers
  #   the disabling function of an optional input field
  def disable_switch_data(pwnfx_scope)
    pwnfx_tag_id = pwnfx_scope + '_field'
    { pwnfx_disable_scope: pwnfx_scope, pwnfx_disable: pwnfx_tag_id,
      pwnfx_disable_trigger: 'checked' }
  end
end
