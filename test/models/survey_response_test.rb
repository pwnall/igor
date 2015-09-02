require 'test_helper'

class SurveyResponseTest < ActiveSupport::TestCase
  before do
    @course = courses(:main)
    @survey = @course.surveys.build name: 'new survey', published: true,
                                    due_at: Time.current
    @response = @survey.responses.build user: users(:dexter)
  end

  let(:response) { survey_responses(:dexter_ps1) }

  it 'validates the setup response' do
    assert @response.valid?, @response.errors.full_messages
  end

  it 'requires a user' do
    @response.user = nil
    assert @response.invalid?
  end

  it 'requires the user to be a registered student or a course/site admin' do
    @response.user = users(:inactive)
    assert @response.invalid?

    @response.user = users(:main_staff)
    assert @response.valid?
  end

  it 'requires a survey' do
    @response.survey = nil
    assert @response.invalid?
  end

  it 'forbids a student from having multiple responses to a survey' do
    @response.survey = surveys(:ps1)
    assert @response.invalid?
  end

  describe '#get_survey_course' do
    it "sets the response's course, if nil, to that of the survey" do
      assert_nil @response.course
      @survey.save!
      assert_equal @survey.course, @response.course
    end
  end

  it "requires that the course matches the survey's course" do
    @response.course = courses(:not_main)
    assert @response.invalid?
  end

  it 'destroys dependent records' do
    assert_not_empty response.answers

    response.destroy

    assert_empty response.answers.reload
  end

  describe '#can_read?' do
    it 'lets only the author and course/site admins view the response' do
      assert_equal true, response.can_read?(users(:dexter))
      assert_equal false, response.can_read?(users(:robot))
      assert_equal false, response.can_read?(users(:main_grader))
      assert_equal true, response.can_read?(users(:main_staff))
      assert_equal true, response.can_read?(users(:admin))
      assert_equal false, response.can_read?(users(:deedee))
      assert_equal false, response.can_read?(nil)
    end
  end

  describe '#build_answers' do
    let(:existing_answers) { response.answers }

    it 'ensures there is one answer for each survey question' do
      assert_operator response.answers.length, :<,
          response.survey.questions.length

      response.build_answers

      assert_equal response.survey.questions.to_set,
          response.answers.map(&:question).to_set
    end

    it 'does not alter existing answers' do
      response.build_answers
      assert_empty existing_answers - response.answers
    end

    it 'does not save newly build answers' do
      response.build_answers
      (response.answers - existing_answers).each do |answer|
        assert_equal true, answer.new_record?
      end
    end
  end
end
