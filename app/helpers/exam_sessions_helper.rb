module ExamSessionsHelper
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
      button_to text, check_in_exam_session_path(exam_session,
          course_id: exam_session.course)
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
    if start_time.to_date === end_time.to_date
      start_time.to_s(:exam_session_datetime) + ' - ' +
      end_time.to_s(:exam_session_time)
    else
      start_time.to_s(:exam_session_datetime) + ' - ' +
      end_time.to_s(:exam_session_datetime)
    end
  end
end
