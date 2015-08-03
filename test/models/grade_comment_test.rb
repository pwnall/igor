require 'test_helper'

class GradeCommentTest < ActiveSupport::TestCase
  before do
    @comment = GradeComment.new grade: grades(:deedee_assessment_quality),
        grader: users(:main_grader), comment: 'Nice work!'
  end

  let(:comment) { grade_comments(:dexter_assessment_overall) }

  it 'validates the setup grade comment' do
    assert @comment.valid?
  end

  it 'requires a grade' do
    @comment.grade = nil
    assert @comment.invalid?
  end

  it 'forbids a grade from having multiple comments' do
    @comment.grade = grades(:dexter_assessment_overall)
    assert @comment.invalid?
  end

  it 'requires a grader' do
    @comment.grader = nil
    assert @comment.invalid?
  end

  it 'requires a comment' do
    @comment.comment = nil
    assert @comment.invalid?
  end

  it 'rejects lengthy comments' do
    @comment.comment = 'a' * (4.kilobytes + 1)
    assert @comment.invalid?
  end
end
