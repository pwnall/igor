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
    
    # MIT name and real name
    pdf.font "Courier"
    target_title = target.respond_to?(:email) ?
         target.email.split('@', 2).first : target.name
    pdf.text target_title, :align => :left, :size => 36
    pdf.font "Times-Roman"
    if target.respond_to?(:users)
      target.users.each do |user|
        pdf.text((user.profile.nil? ? user.name :
                  user.profile.real_name),
                 :align => :left, :size => 24)
        
      end
      v_offset = 24 * target.users.length
    else
      pdf.text((target.profile.nil? ? 'no real name on file' :
                target.profile.real_name),
               :align => :left, :size => 24)
      v_offset = 24
    end
    
    # Submissions
    pdf.y = 792 - 36 - (36 + 24 + v_offset) - 40
    pdf.font "Times-Roman"
    table_data = assignment.deliverables.map do |d|
      s = submissions[d.id]
      if s.nil?
        [d.name, 'N / A', 'no submission', 'N / A', 'N / A']
      else
        submitted_text = (s.updated_at < d.assignment.deadline) ?
            'on time' : 'late by ' +
            distance_of_time_in_words(d.assignment.deadline, s.updated_at)
        if target.respond_to?(:users)
          submitted_text += ' by ' +
              (user.profile.nil? ? user.name : user.profile.real_name)
        end
        [d.name, 
         number_to_human_size(s.code.size),
         (s.run_result.nil? ? 'no diagnostic' : s.run_result.diagnostic),
         submitted_text,
         (s.updated_at < d.assignment.deadline) ? 'not needed' : '']
      end
    end

    pdf.text "Submissions for #{assignment.name}", :size => 24, :align => :center
    pdf.table table_data, :size => 12, :row_colors => ['f3f3f3', 'ffffff'],
        :headers => ['Name', 'Size', 'Validation', 'Submitted', 'Extension'],
        :align => { 0 => :left, 1 => :right, 2 => :left, 3 => :center,
                    4 => :center},
        :column_widths => {0 => 170, 1 => 70, 2 => 100, 3 => 110, 4 => 80},
        :align_headers => :left, :position => :center do |t|
      t.row(0).style :font_style => :bold, :background_color => 'ffffff'
    end
    pdf.y -= 2
    pdf.text "Please contact the course staff as soon as possible " +
             "if any of your submissions is not listed above.",
             :align => :center, :size => 13

    # Grades
    pdf.y -= 40
    pdf.font "Times-Roman"
    table_data = assignment.assignment_metrics.map do |m|        
      [m.name,
       '',
       '',
       m.max_score.to_s,
       ''
      ]
    end
    pdf.text "Grades for #{assignment.name}", :size => 24, :align => :center
    pdf.table table_data, :font_size => 12, :row_colors => ['f3f3f3', 'ffffff'],
        :headers => ['Problem', 'Grade', 'Grader', 'Points', 'Comments'].map { |text| Prawn::Table::Cell.new(:text => text, :font_style => :bold)},
        :align => { 0 => :left, 1 => :right, 2 => :center, 3 => :right,
                    4 => :center},
        :column_widths => { 0 => 140, 1 => 70, 2 => 70, 3 => 70, 4 => 110},
        :align_headers => :left, :position => :center do |t|
      t.row(0).style :font_style => :bold, :background_color => 'ffffff'
    end
    pdf.y -= 2
    pdf.text "Please check the course site if any of your grades is not " +
             "listed above.", :align => :center, :size => 13
    
    # Total score
    pdf.font_size = 24
    pdf.y = 792 - 36 - 24
    max_score = assignment.assignment_metrics.map(&:max_score).sum
    pdf.text "/ #{max_score}", :align => :right, :size => 36
                
    if file_name.nil?
      pdf.to_s
    else
      pdf.render_file file_name
    end
  end
end
