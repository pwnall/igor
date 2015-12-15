Time::DATE_FORMATS.merge!(
  datetime_local_field: '%Y-%m-%dT%T',
  deadline_short: '%b %e',
  deadline_long: '%a %b %e, %l:%M%p',
  exam_session_date: '%a %b %e',
  exam_session_time: '%l:%M%P',
  exam_session_datetime: '%a %b %e, %l:%M%P',
  extension_date: '%m/%d/%y',
  extension_time: '%l:%M %p',
  submission_short: '%b %e, %l:%M%p',
  submission_long: '%b %d %I:%M:%S%p',
  time_slot_short: '%l:%M%P',
  time_slot_long: '%l:%M%P (%Z)'
)
