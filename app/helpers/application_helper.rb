# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def add_site_status(page, message, is_notice)
    page.insert_html :bottom, 'site_status_container', :partial => 'layouts/status', :object => message.html_safe, :locals => {:is_notice => is_notice}    
  end
  
  def time_delta(dtime, ref_time = Time.now)
    ((dtime < ref_time) ? "%s ago" : "in %s") % distance_of_time_in_words(dtime, ref_time, true)
  end

  def display_name_for_user(user, format = :short)
    return user.real_name if format == :really_short
      
    base = if user.profile.nil? then "<#{user.athena_id}@mit>" else "#{user.profile.real_name} <#{user.athena_id}@mit>" end
    base = "#{user.name} [#{base}]" if format == :long
    return base
  end

  def display_name_for_recitation_section(recitation_section, format = :short)
    "R#{'%02d' % recitation_section.serial} - #{recitation_section.time}, #{recitation_section.location} #{display_name_for_user recitation_section.leader, :really_short}"
  end
  
  def to_table_array(enumerable, columns, empty_cell = nil)
    table = []
    current_row = []
    enumerable.each do |item|
      current_row << item
      next if current_row.length < columns
      table << current_row; current_row = []
    end
    return table if current_row.empty? 
    
    current_row << empty_cell while current_row.length < columns
    table << current_row
    return table
  end
end
