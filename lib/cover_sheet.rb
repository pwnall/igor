# compiles nice cover sheets
require 'pdf/writer'
require 'pdf/simpletable'

module CoverSheet
  # crap included because we're doing view stuff in the controller :(
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ApplicationHelper
  
  def cover_sheet_for_assignment(target, assignment, file_name)
    submissions = target.submissions.
        where(:deliverable_id => assignment.deliverables.map(&:id)).
        index_by { |s| s.deliverable.id }
  
    # letter: 612pts x 792pts
    pdf = PDF::Writer.new :paper => 'LETTER', :orientation => :portrait
    
    # course footer
    course = Course.main
    pdf.select_font "Helvetica"
    pdf.y = 40 + 18 * 4
    pdf.font_size = 14
    pdf.text "#{course.number} - #{course.title}", :justification => :center
    pdf.text "Massachusetts Institute of Technology", :justification => :center
    pdf.text "Department of Electrical Engineering and Computer Science",
             :justification => :center
    pdf.move_pointer 14
    pdf.text "Designed by Victor Costan", :justification => :center,
                                          :font_size => 8

    # Recitation Section
    pdf.y = 792 - 36
    pdf.select_font "Times-Roman"
    user = target.respond_to?(:users) ? target.users.first : target
    if Course.main.has_recitations?
      if user.profile and user.profile.recitation_section
        section_title =
            display_name_for_recitation_section user.profile.recitation_section
      else
        section_title = "R00 - 00am, No Section Info"
      end
    else
      section_title = ""
    end
    pdf.text section_title, :justification => :left, :font_size => 24
    
    # MIT name and real name
    pdf.select_font "Courier"
    target_title = target.respond_to?(:email) ?
         target.email.split('@', 2).first : target.name
    pdf.text target_title, :justification => :left, :font_size => 36
    pdf.select_font "Times-Roman"
    if target.respond_to?(:users)
      target.users.each do |user|
        pdf.text((user.profile.nil? ? user.name :
                  user.profile.real_name),
                 :justification => :left, :font_size => 24)
        
      end
      v_offset = 24 * target.users.length
    else
      pdf.text((target.profile.nil? ? 'no real name on file' :
                target.profile.real_name),
               :justification => :left, :font_size => 24)
      v_offset = 24
    end
    
    # Submissions
    pdf.y = 792 - 36 - (36 + 24 + v_offset) - 40
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
      
      table.column_order.push('name', 'size', 'diagnostic', 'submitted',
                              'extension')
      [['name', 'Name', 170, :left], ['size', 'Size', 70, :right],
       ['diagnostic', 'Diagnostic', 100, :left],
       ['submitted', 'Submitted', 110, :center],
       ['extension', 'Extension', 80, :center]
      ].each do |cname, ctitle, cpts, cjust|
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
          s = submissions[d.id]
          if s.nil?
            {'name' => d.name, 'size' => 'N / A',
             'diagnostic' => 'no submission', 'time' => 'N / A',
             'extension' => 'N / A'}
          else
            submitted_text = (s.updated_at < d.assignment.deadline) ?
                'on time' : 'late by ' +
                distance_of_time_in_words(d.assignment.deadline, s.updated_at)
            if target.respond_to?(:users)
              submitted_text += ' by ' +
                  (user.profile.nil? ? user.name : user.profile.real_name)
            end
            {'name' => d.name, 
             'size' => number_to_human_size(s.code.size),
             'diagnostic' => (s.run_result.nil? ? 'no diagnostic' :
                                                  s.run_result.diagnostic),
             'submitted' => submitted_text,
             'extension' => (s.updated_at < d.assignment.deadline) ? 'not needed' : ''}
          end
        end
      end
      
      table.render_on pdf
    end
    pdf.text "Please contact the course staff as soon as possible " +
             "if any of your submissions is not listed above.",
             :justification => :center, :font_size => 13

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
      
      table.column_order.push 'problem', 'grade', 'grader', 'points', 'comments'
      [['problem', 'Problem', 140, :left], 
       ['grade', 'Grade', 80, :right], 
       ['grader', 'Grader', 70, :center],
       ['points', 'Points', 70, :right], 
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
    pdf.text "Please check the course site if any of your grades is not listed above.", :justification => :center, :font_size => 13
    
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
