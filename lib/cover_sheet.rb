# compiles nice cover sheets
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
    pdf = Prawn::Document.new :page_size => 'LETTER', :page_layout => :portrait
    
    # course footer
    course = Course.main
    pdf.font "Helvetica"
    pdf.y = 40 + 18 * 4
    pdf.font_size = 14
    pdf.text "#{course.number} - #{course.title}", :align => :center
    pdf.text "Massachusetts Institute of Technology", :align => :center
    pdf.text "Department of Electrical Engineering and Computer Science",
             :align => :center
    pdf.y -= 14
    pdf.text "Designed by Victor Costan", :align => :center, :size => 8

    # Recitation Section
    pdf.y = 792 - 36
    pdf.font "Times-Roman"
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
    pdf.text section_title, :align => :left, :size => 24
    
    # MIT e-mail and real name
    pdf.font "Courier"
    target_title = target.respond_to?(:email) ?
         target.email.split('@', 2).first : target.name
    pdf.text target_title, :align => :left, :size => 36
    pdf.font "Times-Roman"
    if target.respond_to?(:users)
      target.users.each do |user|
        pdf.text(user.email, :align => :left, :size => 24)
      end
      v_offset = 24 * target.users.length
    else
      pdf.text((target.profile.nil? ? 'no real name on file' :
                target.profile.name),
               :align => :left, :size => 24)
      v_offset = 24
    end
    
    # Submissions
    pdf.y = 792 - 36 - (36 + 24 + v_offset) - 40
    pdf.font "Times-Roman"
    table_data = 

    pdf.text "Submissions for #{assignment.name}", :size => 24, :align => :center
    table_data = [['Name', 'Size', 'Validation', 'Submitted', 'Extension']] +
                 assignment.deliverables.map do |d|
      s = submissions[d.id]
      if s.nil?
        [d.name, 'N / A', 'no submission', 'N / A', 'N / A']
      else
        submitted_text = (s.updated_at < d.assignment.deadline) ?
            'on time' : 'late by ' +
            distance_of_time_in_words(d.assignment.deadline, s.updated_at)
        if target.respond_to?(:users)
          submitted_text += ' by ' + user.name
        end
        [d.name, 
         number_to_human_size(s.db_file.f.size),
         (s.check_result.nil? ? 'no diagnostic' : s.check_result.diagnostic),
         submitted_text,
         (s.updated_at < d.assignment.deadline) ? 'not needed' : '']
      end
    end
    pdf.table table_data, :header => true do |table|
      table.column_widths = [170, 70, 100, 110, 80]
      table.row_colors = ['ffffff', 'f3f3f3']
      table.cells.size = 12
      table.row(0).font_style = :bold
      [:left, :right, :left, :center, :center].each_with_index do |a, i|      
        table.column(i).align = a
      end
    end
    pdf.y -= 2
    pdf.text "Please contact the course staff as soon as possible " +
             "if any of your submissions is not listed above.",
             :align => :center, :size => 13

    # Grades
    pdf.y -= 40
    pdf.font "Times-Roman"
    table_data = [['Problem', 'Grade', 'Grader', 'Points', 'Comments']] +
                 assignment.metrics.map do |m|        
      [m.name,
       '',
       '',
       m.max_score.to_s,
       ''
      ]
    end
    pdf.text "Grades for #{assignment.name}", :size => 24, :align => :center
    pdf.table table_data, :header => true do |table|
      table.column_widths = [140, 70, 70, 70, 180]
      table.cells.size = 12
      table.row_colors = ['ffffff', 'f3f3f3']
      table.row(0).font_style = :bold
      [:left, :right, :center, :right, :center].each_with_index do |a, i|
        table.column(i).align = a
      end
    end
    pdf.y -= 2
    pdf.text "Please check the course site if any of your grades is not " +
             "listed above.", :align => :center, :size => 13
    
    # Total score
    pdf.font_size = 24
    pdf.y = 792 - 36 - 24
    max_score = assignment.metrics.map(&:max_score).sum
    pdf.text "/ #{max_score}", :align => :right, :size => 36
    
    
    pdf.start_new_page
    
    if file_name.nil?
      pdf.render
    else
      pdf.render_file file_name
    end
  end
end
