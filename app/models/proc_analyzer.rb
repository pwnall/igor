# == Schema Information
#
# Table name: analyzers
#
#  id             :integer(4)      not null, primary key
#  deliverable_id :integer(4)      not null
#  type           :string(32)      not null
#  input_file     :string(64)
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
        result.diagnostic = 'Valid PDF'
        result.log = 'valid PDF header and trailer encountered'
      else
        result.diagnostic = 'Incomplete PDF'
        result.log = 'missing trailer; the file is incomplete'
      end
    else
      result.diagnostic = 'Bad PDF'
      result.log = 'missing header; the file is not a PDF'
    end
    result.save!
  end
end
