class FeedbackController < ApplicationController
  # GET /_/feedback/new
  def new
    title = 'User Feedback: '
    body = <<END_BODY
Please add a quick summary of the issue to the title above, and describe your
issue here. Do not remove the text below.

---
Server: #{request.base_url}
Referer: #{request.referer}
Rails: #{Rails.version}
Ruby: #{RUBY_DESCRIPTION}
END_BODY
    redirect_to "https://github.com/pwnall/igor/issues/new?" +
        URI.encode_www_form(title: title, body: body)
  end
end
