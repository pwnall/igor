module ProfilePhotosHelper
  # Send users here to get a Gravatar that shows up as their profile photo.
  def gravatar_signup_url(user)
    "https://en.gravatar.com/site/signup/#{CGI.escape(user.email)}"
  end
end
