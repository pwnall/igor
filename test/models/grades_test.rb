require 'test_helper'

describe Grade do
  fixtures :users, :grades, :assignment_metrics
  
  describe 'when creating a new grade' do
    before do
      @grade = Grade.new subject: users(:dexter), grader: users(:admin), subject_type: 'User', metric: assignment_metrics(:ps1_p1), score: 3.0
    end

    it 'accepts valid grades' do
      assert @grade.valid?
    end
    
    it 'insists on the uniqueness of metric_id for a new grade of a user' do
      # This test ensures that there can't be more than one grade stored for a particular assignment of a particular user
      @grade.metric = assignment_metrics :assessment_overall
      assert_equal false, @grade.valid?
    end 

    it 'requires a metric' do
      @grade.metric = nil
      assert_equal false, @grade.valid?
    end

    it 'requires a grader' do
      @grade.grader = nil
      assert_equal false, @grade.valid?
    end

    it 'rejects a grade submitted by a non-grader' do
      @grade.grader = users :dexter
      assert_equal false, @grade.valid? 
    end

    it 'requires a subject' do
      @grade.subject = nil
      assert_equal false, @grade.valid?
    end

    it 'requires a numeric score' do
      bad_scores = ['string', '01s']
      good_scores = [1, 0.1, 1.3333, '01', '5.3']
      bad_scores.each do |score|
        @grade.score = score
        assert_equal false, @grade.valid?
      end
      good_scores.each do |score|
        @grade.score = score
        assert @grade.valid?
      end
    end
  end

  describe '#with_subject' do
    before do
      @grades = Grade.with_subject users(:dexter)
    end

    it 'verifies each grade belongs to dexter' do
      @grades.each do |grade|
        assert_equal grade.subject, users(:dexter)
      end
    end

    it 'verifies each grade belongs to dexter using the users method' do
      @grades.each do |grade|
        assert_equal grade.users.first, users(:dexter)
      end
    end
  end
end
