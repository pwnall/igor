module ExamSessionsHelper
  # Options tags for the sessions held for the given exam.
  def exam_session_checkin_options(exam, selected=nil)
    sessions = exam.exam_sessions.by_start_time.by_name
    options_from_collection_for_select sessions, :id, :name,
        (selected && selected.id)
  end

  # A check-in button, or text describing the user's check-in status.
  def attendance_status_display(exam_session, user)
    status = exam_session.ui_attendance_status_for user
    case status
    when :available
      text = 'Check in'
      tag_type = :button
      tooltip_text = 'Check in to take the exam at this session.'
    when :full
      text = 'Room full'
      tooltip_text = 'You must check-in elsewhere.'
    when :unavailable
      text = 'Check in'
      tag_type = :disabled_button
      tooltip_text = 'You have already checked in, or you are not registered for this class.'
    when :confirmed
      text = 'Checked in!'
      tooltip_text = 'You are scheduled to take the exam during this session.'
    when :pending_confirmation
      text = 'Awaiting confirmation'
      tooltip_text = 'A staff member must confirm your attendance.'
    else
      raise "Un-implemented attendance status: #{status}"
    end

    content = case tag_type
    when :button
      button_to text, exam_session_attendances_path(
          exam_session_id: exam_session, course_id: exam_session.course)
    when :disabled_button
      button_tag text, type: 'button', disabled: true
    else
      text
    end
    content_tag :span, content, data: { tooltip: true, disable_hover: false },
        class: 'has-tip top', title: tooltip_text
  end

  # The time range when the given exam session takes place.
  def exam_session_time_tag(exam_session)
    start_time = exam_session.starts_at
    end_time = exam_session.ends_at
    time_components = []
    if start_time.to_date === end_time.to_date
      time_components << start_time.to_s(:exam_session_date) + ', '
      time_components << start_time.to_s(:exam_session_time) + ' - ' +
          end_time.to_s(:exam_session_time)
    else
      time_components << start_time.to_s(:exam_session_datetime) + ' - '
      time_components << end_time.to_s(:exam_session_datetime)
    end
    safe_join(time_components.map { |c| content_tag :span, c, class: 'time' })
  end

  # The start time, or appropriate default, for the given exam session.
  def exam_session_start_time(exam_session)
    # Cannot access assignment directly if the exam is not a persisted record
    assignment = exam_session.exam.assignment
    time = if exam_session.new_record?
      assignment.released_at || assignment.due_at
    else
      exam_session.starts_at
    end
    time.to_s(:datetime_local_field)
  end

  # The end time, or appropriate default, for the given exam session.
  def exam_session_end_time(exam_session)
    time = if exam_session.new_record?
      exam_session.exam.assignment.due_at
    else
      exam_session.ends_at
    end
    time.to_s(:datetime_local_field)
  end
end
