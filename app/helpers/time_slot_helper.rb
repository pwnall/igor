module TimeSlotHelper
  DAYS = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

  # Option tags whose text is the day name, and value is the day's integer.
  #
  # E.g., <option value="0">Monday</option>...<option value="6">Sunday</option>
  def day_select_option_tags
    options_for_select DAYS.map.with_index.to_a
  end

  # Convert the day of the week from an integer to the name of a day.
  #
  # E.g., day_label(0) #=> 'Monday'
  def day_label(day)
    DAYS[day]
  end

  # The day of the week that the given time slot starts.
  def time_slot_day_label(time_slot)
    day_label(time_slot.day)
  end

  # The range of a time slot displayed when viewing time slots.
  #
  # E.g., '10:00am (EDT) - 11:00am (EDT)'
  def time_slot_range_label(time_slot)
    start_time = time_slot.start_time.to_s(:time_slot_long)
    end_time = time_slot.end_time.to_s(:time_slot_long)
    "#{start_time} - #{end_time}"
  end

  # The range of a time slot displayed when viewing recitation conflicts.
  #
  # E.g., '10:00am - 11:00am (EDT)'
  def conflict_time_period_label(start_time, end_time)
    start_time = TimeSlot.time_at(start_time).to_s(:time_slot_short)
    end_time = TimeSlot.time_at(end_time).to_s(:time_slot_long)
    "#{start_time} - #{end_time}"
  end

  # A string representation of the time slot.
  #
  # E.g., 'Monday 10:00am (EDT) - 11:00am (EDT)'
  def time_slot_label(time_slot)
    "#{time_slot_day_label time_slot} #{time_slot_range_label time_slot}"
  end

  # The number of hours and minutes in a time slot. E.g., "1hr 30min"
  #
  # We currently support durations from 0 to 23:59 hours.
  def time_slot_duration(time_slot)
    diff = time_slot.ends_at - time_slot.starts_at
    diff += 2400 if diff < 0
    hour, minute = diff.divmod 100
    result = "#{hour}hr"
    result << " #{minute}min" unless minute == 0
    result
  end

  # A checkbox list of time slots you can allot to the given recitation.
  #
  # TODO(spark008): Make this less ugly. Maybe extract into a partial.
  def time_slot_check_box_list_tag(recitation)
    name = 'recitation_section[time_slot_ids][]'
    blank = hidden_field_tag name, ''
    check_box_list_items = recitation.course.time_slots.map do |ts|
      is_checked = recitation.time_slots.include? ts
      content_tag :li do
        safe_join([
          check_box_tag(name, ts.id, is_checked, id: ts.id),
          label_tag(ts.id, time_slot_label(ts))
        ])
      end
    end
    content_tag :ul, id: 'recitation_section_time_slot_ids' do
      safe_join [blank, check_box_list_items]
    end
  end
end
