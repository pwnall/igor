module UsersHelper
  def user_image_tag(user, options = {})
    user = current_user if user.instance_of? Team
    size = options[:size] || :small
    size_pixels = {small: 20, large: 100}[size]

    url = Gravatar.new(user.email).image_url size: size_pixels, secure: true,
                                             default: :retro
    image_tag url, alt: "avatar for #{user.name}",
              style: "width: #{size_pixels}px; height: #{size_pixels}px;"
  end
end
