module RegistrationsHelper
  include IconsHelper

  # A selection of recitations you can assign to a registered student.
  def recitation_select_tag(registration)
    return unless registration
    name = 'registration[recitation_section_id]'
    recitation_options = registration.course.recitation_sections.map do |rs|
      [display_name_for_recitation_section(rs), rs.id]
    end
    selected = registration.recitation_section_id
    select_tag name, options_for_select(recitation_options, selected),
        prompt: 'Select a section...'
  end

  # A text input field for a recitation conflict in a registration form.
  #
  # @param [ActionView::Helpers::FormBuilder] registration_form the form of the
  #   parent registration
  # @param [TimeSlot] slot the time slot, if it exists, of the conflict
  # @param [Hash<Integer, RecitationConflict>] conflicts existing conflicts for
  #   this registration, indexed by time slot id
  # @return [ActiveSupport::SafeBuffer] the form field tags for a single
  #   recitation conflict
  def conflict_input_tag(registration_form, slot, conflicts)
    return unless slot
    conflict = conflicts[slot.id] || RecitationConflict.new(time_slot: slot)
    registration_form.fields_for :recitation_conflicts, conflict do |cf|
      safe_join([
        cf.text_field(:class_name, size: 8, class: 'form_field'),
        cf.hidden_field(:time_slot_id)
      ])
    end
  end

  # A table cell showing the availability status for a given time slot.
  #
  # @param [TimeSlot] slot the time slot in question
  # @param [Hash<Integer, RecitationConflict>] conflicts existing conflicts,
  #   indexed by time slot id
  # @return [ActiveSupport::SafeBuffer] a <td> tag containing 'free', the
  #   name of the conflicting class, or nothing
  def conflict_td_tag(slot, conflicts)
    conflict = slot && conflicts[slot.id]
    if conflict
      content_tag :td, conflict.class_name, class: 'busy'
    elsif slot
      content_tag :td, 'free', class: 'free'
    else
      content_tag :td, ''
    end
  end
end
