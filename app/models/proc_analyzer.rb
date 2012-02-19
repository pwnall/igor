# == Schema Information
#
# Table name: analyzers
#
#  id             :integer(4)      not null, primary key
#  deliverable_id :integer(4)      not null
#  type           :string(32)      not null
#  auto_grading   :boolean(1)      default(FALSE), not null
#  exec_limits    :text
#  db_file_id     :integer(4)
#  message_name   :string(64)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

# Submission analyzer that calls a method on itself.
class ProcAnalyzer < Analyzer
  # The name of the method to be called.
  validates :message_name, :presence => true, :length => 1..64,
      :inclusion => { :in => %w(analyze_pdf) }
  attr_accessible :message_name
  
  # :nodoc: overrides Analyzer#analyze
  def analyze(submission)
    send self.message_name.to_sym, submission
  end

  # Checks that a submitted file looks like a PDF.
  def analyze_pdf(submission)
    bytes = submission.full_db_file.f.file_contents
    result = submission.analysis
    if bytes[0, 5] == '%PDF-'
      if bytes[([0, bytes.length - 1024].max)..-1] =~ /\%\%EOF/
        result.status = :ok
        result.log = "Valid PDF header and trailer found.\n"
      else
        result.status = :wrong
        result.log = <<LOG_END
PDF has valid header, but no trailer.
The file was most likely truncated during upload :(
LOG_END
      end
    else
      result.status = :wrong
      result.log = "Missing PDF header.\nDid you upload a PDF?\n"
    end
    result.save!
    
    zero_grades(submission) if auto_grading? && result.status != :ok
  end
  
  # Creates zero grades for all the metrics on the submission's assignment.
  #
  # This method does not overwrite existing grades, so that (1) it does not
  # interfere with human graders, and (2) it can coexist with script analyzers
  # that might assign non-zero grades for working code.
  def zero_grades(submission)
    metrics = submission.assignment.metrics
    metrics.each do |metric|
      grade = metric.grade_for submission.user
      next unless grade.new_record?
      grade.score = 0
      grade.grader = User.robot
      grade.save!
    end
  end
end
