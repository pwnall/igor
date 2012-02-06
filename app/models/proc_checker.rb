# == Schema Information
# Schema version: 20110429122654
#
# Table name: submission_checkers
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

# Submission checker that calls a method in SubmissionCheckersController.
class ProcChecker < SubmissionChecker
  # The name of the message to be sent to the controller.
  validates_presence_of :message_name
  
  # :nodoc: overrides SubmissionChecker#check
  def check(submission)
    send self.message_name.to_sym, submission
  end

  # Checks that a submitted file looks like a PDF.
  def validate_pdf(submission)
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
