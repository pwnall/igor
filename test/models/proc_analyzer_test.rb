require 'test_helper'

class ProcAnalyzerTest < ActiveSupport::TestCase
  before do
    deliverable = assignments(:ps1).deliverables.build name: 'Moar answers',
        description: 'No no moar'
    @analyzer = ProcAnalyzer.new deliverable: deliverable, auto_grading: false,
        message_name: 'analyze_pdf'
  end

  let(:analyzer) { analyzers(:proc_assessment_writeup) }
  let(:ok_pdf_submission) { submissions(:dexter_assessment) }
  let(:truncated_pdf_submission) { submissions(:deedee_assessment) }
  let(:py_submission) { submissions(:dexter_code) }

  it 'validates the setup analyzer' do
    assert @analyzer.valid?, @analyzer.errors.full_messages
  end

  describe 'core analyzer functionality' do
    it 'requires a deliverable' do
      @analyzer.deliverable = nil
      assert @analyzer.invalid?
    end

    it 'forbids a deliverable from having multiple analyzers' do
      @analyzer.deliverable = analyzer.deliverable
      assert @analyzer.invalid?
    end

    it 'must state whether grades are automatically updated' do
      @analyzer.auto_grading = nil
      assert @analyzer.invalid?
    end
  end

  it 'requires a proc method name' do
    @analyzer.message_name = nil
    assert @analyzer.invalid?
  end

  describe '#analyze_pdf' do
    it 'logs proper PDFs as :ok' do
      assert_not_nil ok_pdf_submission.file.data
      assert_equal :queued, ok_pdf_submission.analysis.status
      ProcAnalyzer.new.analyze_pdf ok_pdf_submission
      analysis = ok_pdf_submission.analysis.reload
      assert_equal :ok, analysis.status
      assert_equal({}, analysis.scores)
    end

    it 'logs truncated PDFs as :wrong' do
      assert_not_nil truncated_pdf_submission.file.data
      assert_equal :queued, truncated_pdf_submission.analysis.status
      ProcAnalyzer.new.analyze_pdf truncated_pdf_submission
      analysis = truncated_pdf_submission.analysis.reload
      assert_equal :wrong, analysis.status
      assert_equal({'Quality' => 0, 'Overall' => 0}, analysis.scores)
    end

    it 'logs non-PDFs as :wrong' do
      assert_not_nil py_submission.file.data
      assert_equal :queued, py_submission.analysis.status
      ProcAnalyzer.new.analyze_pdf py_submission
      analysis = py_submission.analysis.reload
      assert_equal :wrong, analysis.status
      assert_equal({'Quality' => 0, 'Overall' => 0}, analysis.scores)
    end
  end
end
