require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  before do
    @analysis = Analysis.new submission: submissions(:solo_ps1),
        status: :queued, log: '', private_log: ''
  end

  it 'validates the setup analysis' do
    assert @analysis.valid?, @analysis.errors.full_messages
  end
end
