module UsersHelper
  def user_image_tag(user, options = {})
    size = options[:size] || :small
    size_pixels = {small: 20, large: 100}[size]

    if user.profile and user.profile.photo
      url = user.profile.photo.pic.url({small: :thumb, large: :profile}[size])
    else
      url = Gravatar.new(user.email).image_url size: size_pixels, secure: true,
                                               default: :retro
    end
    image_tag url, alt: "avatar for #{user.name}",
              style: "width: #{size_pixels}px; height: #{size_pixels}px;"
  end

  def user_destroy_link(user, options = {}, &block)
    confirmation = "Completely wipe #{user.email}'s data?"
    options = { method: :delete }.merge! options
    options[:data] ||= {}
    options[:data][:confirm] ||= confirmation
    link_to user, options, &block
  end


  # TODO(costan): this should be outdated and replaced with the model method;
  #               yes, it's important enough that it should be a part of the
  #               model
  def display_name_for_user(user, format = :short)
    return user.name if format == :really_short

    "#{user.name} [#{user.email}]" if format == :long
  end
end
