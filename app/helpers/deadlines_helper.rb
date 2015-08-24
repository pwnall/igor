module DeadlinesHelper
  # A datetime, represented in words.
  def time_delta_in_words(datetime)
    time = time_ago_in_words datetime
    if datetime >= Time.current
      "(in #{time})"
    else
      "(#{time} ago)"
    end
  end
end
