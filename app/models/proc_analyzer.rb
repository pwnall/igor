# == Schema Information
#
# Table name: analyzers
#
#  id                 :integer          not null, primary key
#  deliverable_id     :integer          not null
#  type               :string(32)       not null
#  auto_grading       :boolean          not null
#  exec_limits        :text
#  file_blob_id       :string(48)
#  file_size          :integer
#  file_mime_type     :string(64)
#  file_original_name :string(256)
#  message_name       :string(64)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# Submission analyzer that calls a method on itself.
class ProcAnalyzer < Analyzer
  # The name of the method to be called.
  validates :message_name, presence: true, length: 1..64,
      inclusion: { in: %w(analyze_pdf) }

  # :nodoc: overrides Analyzer#analyze
  def analyze(submission)
    send self.message_name.to_sym, submission
  end

  # Checks that a submitted file looks like a PDF.
  def analyze_pdf(submission)
    bytes = submission.file.data
    analysis = submission.analysis
    if bytes[0, 5] == '%PDF-'
      if bytes[([0, bytes.length - 1024].max)..-1] =~ /\%\%EOF/
        analysis.status = :ok
        analysis.log = "Valid PDF header and trailer found.\n"
      else
        analysis.status = :wrong
        analysis.log = <<LOG_END
PDF has valid header, but no trailer.
The file was most likely truncated during upload :(
LOG_END
      end
    else
      analysis.status = :wrong
      analysis.log = "Missing PDF header.\nDid you upload a PDF?\n"
    end
    analysis.private_log = ''

    scores = {}
    if analysis.status != :ok
      submission.assignment.metrics.each do |metric|
        scores[metric.name] = 0
      end
    end
    analysis.scores = scores
    analysis.save!
  end
end
