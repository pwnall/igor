module UsersHelper
  def user_image_tag(user, options = {})
    size = options[:size] || :large
    size_pixels = {:small => 18, :large => 36}[size]
    image_tag user.gravatar_url(:size => size_pixels),
              :alt => "gravatar for #{user.name}"
  end
end
