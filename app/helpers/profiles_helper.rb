module ProfilesHelper
  include IconsHelper  # For (in)valid_icon_tag.

  # The validation message for the given e-mail's format.
  #
  # @param [String] email the e-mail address to verify
  # @return [ActiveSupport::SafeBuffer] the validation message
  def email_format_check(email)
    return if email.blank?
    if email.length < 5
      invalid_icon_tag + ' too short'
    else
      if User.with_email email
        invalid_icon_tag + ' taken'
      elsif !email.chomp.end_with? '.edu'
        invalid_icon_tag + ' must be an .edu address'
      else
        valid_icon_tag + ' available'
      end
    end
  end

  # The validation message for resolving the given e-mail.
  #
  # @param [Hash] ldap_info the EmailResolver output
  # @param [String] email the e-mail address to resolve
  # @return [ActiveSupport::SafeBuffer] the validation message
  def email_resolver_check(ldap_info, email)
    if ldap_info.nil?
      invalid_icon_tag + "#{email} not found" unless email.blank?
    else
      valid_icon_tag + "#{email} found"
    end
  end

  # Predict a student's university based on their email address.
  def guess_university_from_email(email)
    domain = email.split('@').last
    domains = {
      /harvard/ => 'Harvard University',
      /mit/ => 'Massachusetts Institute of Technology',
      /wellesley/ => 'Wellesley College'
    }
    domains.each do |pattern, university|
      return university if domain =~ pattern
    end
  end

  # Intended for use in a select field for the year on a user profile.
  def profile_year_options(profile)
    options = [
      ['Freshman (1)', '1'],
      ['Sophomore (2)', '2'],
      ['Junior (3)', '3'],
      ['Senior (4)', '4'],
      ['Graduate (G)', 'G']
    ]
    # Make the selected option stick in FireFox by putting it first.
    yr_index =
       (0...(options.length)).find { |i| options[i][1] == profile.year } || 0
    options[yr_index...(options.length)] + options[0...yr_index]
  end

  # Intended for use in a select field for the recitation on a user profile.
  def profile_recitation_section_options(profile)
    options = RecitationSection.all.map do |s|
      [display_name_for_recitation_section(s), s.id]
    end
    # Make the selected option stick in FireFox by putting it first.
    rs_index = (0...(options.length)).find do |i|
      options[i][1] == profile.recitation_section_id
    end
    rs_index ||= 0
    options[rs_index...(options.length)] + options[0...rs_index]
  end
end
