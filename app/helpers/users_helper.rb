module UsersHelper
  def user_image_tag(user, options = {})
    size = options[:size] || :small
    size_pixels = {:small => 36, :large => 100}[size]
    image_tag user.gravatar_url(:size => size_pixels),
              :alt => "gravatar for #{user.name}",
              :style => "width: #{size_pixels}px; height: #{size_pixels}px;"
  end
  
  # TODO(costan): this should be outdated and replaced with the model method;
  #               yes, it's important enough that it should be a part of the
  #               model
  def display_name_for_user(user, format = :short)
    return user.real_name if format == :really_short
      
    base = user.profile ?
        "#{user.profile.real_name} <#{user.athena_id}@mit>" :
        "<#{user.athena_id}@mit>"
    base = "#{user.name} [#{base}]" if format == :long
    return base
  end  
end
