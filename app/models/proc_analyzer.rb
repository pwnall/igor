# == Schema Information
# Schema version: 20110429122654
#
# Table name: analyzers
#
#  id             :integer(4)      not null, primary key
#  type           :string(32)      not null
#  deliverable_id :integer(4)      not null
#  message_name   :string(64)
#  db_file_id     :integer(4)
#  time_limit     :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

# Submission analyzer that calls a method on itself.
class ProcAnalyzer < Analyzer
  # The name of the method to be called.
  validates :message_name, :presence => true, :length => 1..64,
      :inclusion => { :in => %w(analyze_pdf) }
  
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
        result.diagnostic = 'valid PDF'
        result.stdout = 'valid PDF header and trailer encountered'
        result.stderr = ''
      else
        result.diagnostic = 'incomplete PDF'
        result.stdout = ''
        result.stderr = 'missing trailer; the file is incomplete'
      end
    else
      result.diagnostic = 'bad PDF'
      result.stdout = ''
      result.stderr = 'missing header; the file is not a PDF'
    end
    result.save!
  end
end
