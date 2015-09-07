require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  before do
    @analysis = Analysis.new submission: submissions(:solo_ps1),
        status: :queued, log: '', private_log: ''
  end

  let(:analysis) { analyses(:dexter_assessment) }
  let(:student_author) { analysis.submission.subject }
  let(:student_not_author) { users(:deedee) }

  it 'validates the setup analysis' do
    assert @analysis.valid?, @analysis.errors.full_messages
  end

  it 'requires a submission' do
    @analysis.submission = nil
    assert @analysis.invalid?
  end

  it 'requires a status' do
    assert_raise ArgumentError do
      @analysis.status = nil
    end
  end

  it 'requires a log' do
    @analysis.log = nil
    assert @analysis.invalid?
  end

  it 'requires a private log' do
    @analysis.private_log = nil
    assert @analysis.invalid?
  end

  describe '#can_read?' do
    it 'forbids non-author students from viewing an analysis' do
      assert_equal true, analysis.can_read?(student_author)
      assert_equal true, analysis.can_read?(users(:robot))
      assert_equal true, analysis.can_read?(users(:main_grader))
      assert_equal true, analysis.can_read?(users(:main_staff))
      assert_equal true, analysis.can_read?(users(:admin))
      assert_equal false, analysis.can_read?(student_not_author)
      assert_equal false, analysis.can_read?(nil)
    end
  end
end
