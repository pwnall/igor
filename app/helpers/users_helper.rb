module UsersHelper
  def user_image_tag(user, options = {})
    size = options[:size] || :small
    size_pixels = {:small => 36, :large => 100}[size]
    image_tag user.gravatar_url(:size => size_pixels),
              :alt => "gravatar for #{user.name}",
              :style => "width: #{size_pixels}px; height: #{size_pixels}px;"
  end
end
