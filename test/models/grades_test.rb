require 'test_helper'

describe Grade do
  fixtures :users, :grades, :assignment_metrics

  before do
    @grade = grades :dexter_assessment
  end

  it 'validates the grade' do
    assert @grade.valid?
  end

  it 'requires a metric' do
    assert_not_nil @grade.metric
  end

  it 'requires a grader' do
    assert_not_nil @grade.grader
  end

  it 'rejects a grade graded by a non-grader' do
    @grade.grader = users :dexter
    assert_equal false, @grade.valid? 
  end

  it 'requires a subject' do
    assert_not_nil @grade.subject
  end

  it 'requires a numeric score' do
    assert @grade.score.is_a? Numeric
  end

end
