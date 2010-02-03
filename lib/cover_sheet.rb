# compiles nice cover sheets
require 'pdf/writer'
require 'pdf/simpletable'

module CoverSheet
  # crap included because we're doing view stuff in the controller :(
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ApplicationHelper
  
  def cover_sheet_for_assignment(user, assignment, file_name)
    u_submissions = user.submissions.find(:all, :conditions => {:deliverable_id => assignment.deliverables.map { |d| d.id } }).index_by { |s| s.deliverable.id }
  
    # letter: 612pts x 792pts
    pdf = PDF::Writer.new :paper => 'LETTER', :orientation => :portrait
    
    # course footer
    pdf.select_font "Helvetica"
    pdf.y = 40 + 18 * 3
    pdf.font_size = 14
    pdf.text "6.006 - Introduction to Algorithms", :justification => :center
    pdf.text "Massachusetts Institute of Technology", :justification => :center
    pdf.text "Department of Electrical Engineering and Computer Science", :justification => :center

    # Section, MIT name and real name
    pdf.y = 792 - 36
    pdf.select_font "Times-Roman"
    pdf.text(((user.profile.nil? or user.profile.recitation_section.nil?) ? "R00 - 00am, No Section Info" : display_name_for_recitation_section(user.profile.recitation_section)), :justification => :left, :font_size => 24)
    pdf.select_font "Courier"
    pdf.text user.email.split('@', 2)[0], :justification => :left, :font_size => 36
    pdf.select_font "Times-Roman"
    pdf.text user.profile.nil? ? 'no real name on file' : user.profile.real_name, :justification => :left, :font_size => 24
    
    # Submissions
    pdf.y = 792 - 36 - (36 + 24 + 24) - 40
    pdf.select_font "Times-Roman"
    PDF::SimpleTable.new do |table|
      table.font_size = 12
      table.heading_font_size = 14
      table.orientation = :center
      table.shade_rows = :striped
      table.shade_color = Color::RGB.from_fraction(1, 1, 1)
      table.shade_color2 = Color::RGB.from_fraction(0.95, 0.95, 0.95)
      table.title = "Submissions for #{assignment.name}"
      table.title_font_size = 24
      
      table.column_order.push('name', 'size', 'diagnostic', 'time', 'extension')
      [['name', 'Name', 170, :left], ['size', 'Size', 70, :right], ['diagnostic', 'Diagnostic', 100, :left],
       ['time', 'Time', 110, :center], ['extension', 'Extension', 80, :center]].each do |cname, ctitle, cpts, cjust|
        table.columns[cname] = PDF::SimpleTable::Column.new(cname) do |column|
          column.heading = PDF::SimpleTable::Column::Heading.new do |heading|
            heading.title = ctitle
            heading.bold = true
            heading.justification = :left
          end
          column.justification = cjust
          column.width = cpts
        end
      end      

      if assignment.deliverables.empty?
        table.data = [{}]
      else
        table.data = assignment.deliverables.map do |d|
          s = u_submissions[d.id]
          if s.nil?
            {'name' => d.name, 'size' => 'N / A', 'diagnostic' => 'no submission', 'time' => 'N / A', 'extension' => 'N / A'}
          else
            {'name' => d.name, 
             'size' => number_to_human_size(s.code.size), 'diagnostic' => s.run_result.nil? ? 'no diagnostic' : s.run_result.diagnostic,
             'time' => (s.updated_at < d.assignment.deadline) ? 'on time' : "late by #{distance_of_time_in_words(d.assignment.deadline, s.updated_at)}",
             'extension' => (s.updated_at < d.assignment.deadline) ? 'not needed' : ''}
          end
        end
      end
      
      table.render_on pdf
    end
    pdf.text "Please contact the course staff as soon as possible if one of your submissions is not listed above.", :justification => :center, :font_size => 13

    # Grades
    pdf.move_pointer 40
    pdf.select_font "Times-Roman"
    PDF::SimpleTable.new do |table|
      table.font_size = 12
      table.heading_font_size = 14
      table.orientation = :center
      table.shade_rows = :striped
      table.shade_color = Color::RGB.from_fraction(1, 1, 1)
      table.shade_color2 = Color::RGB.from_fraction(0.95, 0.95, 0.95)
      table.title = "Grades for #{assignment.name}"
      table.title_font_size = 24
      table.row_gap = 6
      
      table.column_order.push('problem', 'grade', 'grader', 'points', 'comments')
      [['problem', 'Problem', 140, :left], 
       ['grade', 'Grade', 80, :right], 
       ['grader', 'Grader', 70, :center],
       ['points', 'Gradest', 70, :right], 
       ['comments', 'Comments', 110, :center]].each do |cname, ctitle, cpts, cjust|
        table.columns[cname] = PDF::SimpleTable::Column.new(cname) do |column|
          column.heading = PDF::SimpleTable::Column::Heading.new do |heading|
            heading.title = ctitle
            heading.bold = true
            heading.justification = :left
          end
          column.justification = cjust
          column.width = cpts
        end
      end      

      if assignment.assignment_metrics.empty?
        table.data = [{}]
      else
        table.data = assignment.assignment_metrics.map do |m|        
          {'problem' => m.name,
          'points' => m.max_score.to_s,
          'grader' => '',
          'graded' => '', 'grade' => '', 'comments' => ''}
        end      
      end
      table.render_on pdf
    end
    pdf.text "Please check the course site if one of your grades is not listed above.", :justification => :center, :font_size => 13
    
    pdf.y = 40 + 24 * 3 + 60
    pdf.font_size = 24
    pdf.text "Total score: #{' ' * 10} out of #{assignment.assignment_metrics.inject(0) { |acc, m| acc + m.max_score }}"
        
    if file_name.nil?
      pdf.to_s
    else
      pdf.save_as file_name
    end
  end
end
