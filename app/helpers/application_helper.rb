# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def loading_image_tag
    image_tag 'ajax-loader.gif', :alt => 'Loading...'
  end
  
  def ok_image_tag
    image_tag 'checkmark.png', :alt => 'OK'
  end
  
  def add_site_status(message, is_notice)
    render :partial => 'layouts/status', :object => message,
           :locals => { :is_notice => is_notice }
  end
  
  def time_delta(dtime, ref_time = Time.now)
    ((dtime < ref_time) ? "%s ago" : "in %s") % distance_of_time_in_words(dtime, ref_time, true)
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
