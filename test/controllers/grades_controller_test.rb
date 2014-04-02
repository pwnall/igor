require 'test_helper'

describe GradesController do
  fixtures :grades, :users, :assignment_metrics

  describe 'authenticated as a normal user' do
    before do
      @user = users :dexter
      set_session_current_user users(:dexter)
    end

    it 'user can view /grades page' do
      get :index
      assert_response :success
    end

    it 'user cannot view other pages' do
      # 403 refers to a forbidden page
      get :editor
      assert_response 403
      post :create
      assert_response 403
      get :request_missing
      assert_response 403
      get :request_report
      assert_response 403
      get :report
      assert_response 403
    end
  end

  describe 'authenticated as a grader' do
    before do
      @grader = users :admin
      set_session_current_user users(:admin)
      @student = users :dexter
      @problem = assignment_metrics :assessment_overall
      @params = { grade: {
          subject_id: @student.to_param, 
          subject_type: 'User',
          metric_id: @problem.to_param, 
          score: 4.0 }, 
          comment: { comment: '' }
          }
    end

    it 'can update existing grades without a comment' do
      scores = [1.0, 1, 0.0, 0]
      scores.each do |score|
        @params[:grade][:score] = score
        post :create, 
            grade: @params[:grade], 
            comment: @params[:comment]
        grade = Grade.where(
            subject_type: 'User',
            subject_id: @student.id,
            metric_id: @problem.id)
        assert_equal score, grade.first.score
        assert_equal nil, grade.first.comment
      end
    end

    it 'can create new grades without a comment' do
      # Change problem to one that has not been already graded
      @params[:grade][:metric_id] = assignment_metrics(:assessment_quality).id
      assert_difference 'Grade.count' do
        post :create, 
            grade: @params[:grade], 
            comment: @params[:comment]
        assert_response :success
        assert_equal nil, Grade.where(
            subject_type: 'User',
            subject_id: @student.id,
            metric_id: @problem.id).first.comment
      end
    end

    it 'can create a new comment and update an old one on existing and new grades' do
      problems = [@problem, assignment_metrics(:assessment_quality)]
      problems.each do |problem|
        @params[:grade][:metric_id] = problem.id
        assert_difference 'GradeComment.count' do
          post :create, 
              grade: @params[:grade], 
              comment: { comment: 'New comment!' }
          assert_response :success
          assert_equal 'New comment!', Grade.where(
              subject_type: 'User',
              subject_id: @student.id,
              metric_id: problem.id).first.comment.comment
        end
        post :create, 
            grade: @params[:grade], 
            comment: { comment: 'Changed comment!' }
        assert_response :success
        assert_equal 'Changed comment!', Grade.where(
            subject_type: 'User',
            subject_id: @student.id,
            metric_id: problem.id).first.comment.comment
      end
    end
  end
end
