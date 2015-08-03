require 'test_helper'

class PrerequisiteAnswerTest < ActiveSupport::TestCase
  before do
    @answer = PrerequisiteAnswer.new registration: registrations(:dexter),
        prerequisite: prerequisites(:unanswered), took_course: true
  end

  let(:answer) { prerequisite_answers(:dexter_math) }

  it 'validates the setup prerequisite answer' do
    assert @answer.valid?
  end

  it 'requires a registration' do
    @answer.registration = nil
    assert @answer.invalid?
  end

  it 'requires a prerequisite' do
    @answer.prerequisite = nil
    assert @answer.invalid?
  end

  it 'forbids a registrant from having multiple answers for a prerequisite' do
    @answer.prerequisite = prerequisites(:math)
    assert @answer.invalid?
  end

  describe '#registration_course_matches_prerequisite' do
    it 'requires the prerequisite to belong to the registered course' do
      answer.prerequisite = prerequisites(:not_main)
      assert answer.invalid?
    end
  end

  it 'must state whether the course has been taken' do
    @answer.took_course = nil
    assert @answer.invalid?
  end

  it 'rejects lengthy waiver answers' do
    @answer.waiver_answer = 'w' * 4.kilobytes
    assert @answer.invalid?
  end

  it 'requires a waiver answer if :took_course is false' do
    @answer.took_course = false
    @answer.waiver_answer = nil
    assert @answer.invalid?
  end

  describe '#waiver_answer=' do
    it 'converts empty strings to nil' do
      @answer.waiver_answer = ''
      assert_nil @answer.waiver_answer
    end

    it 'does not alter non-empty strings' do
      @answer.waiver_answer = 'wow'
      assert_equal 'wow', @answer.waiver_answer
    end
  end
end
