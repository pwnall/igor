require 'test_helper'

class AssignmentsHelperTest < ActionView::TestCase
  include AssignmentsHelper

  let(:unreleased_exam) { assignments(:main_exam) }
  let(:unreleased_assignment) { assignments(:ps3) }
  let(:released_assignment) { assignments(:ps1) }
  let(:grades_unreleased_assignment) { assignments(:ps2) }

  describe '#unpublish_confirmation' do
    describe 'assignment released, grades unpublished' do
      before do
        @assignment = grades_unreleased_assignment
        assert_equal true, grades_unreleased_assignment.published?
        assert_equal false, grades_unreleased_assignment.grades_published?
      end

      it 'returns nil' do
        assert_nil unpublish_confirmation(@assignment)
      end
    end

    describe 'assignment released, grades published' do
      before do
        @assignment = released_assignment
        assert_equal true, released_assignment.published?
        assert_equal true, released_assignment.grades_published?
      end

      it 'returns a confirmation message' do
        assert_match /Continue\?/, unpublish_confirmation(@assignment)
      end
    end
  end

  describe '#publish_grades_confirmation' do
    describe 'assignment released, grades unpublished' do
      before do
        @assignment = grades_unreleased_assignment
        assert_equal true, grades_unreleased_assignment.published?
        assert_equal false, grades_unreleased_assignment.grades_published?
      end

      it 'returns nil' do
        assert_nil unpublish_confirmation(@assignment)
      end
    end

    describe 'assignment unreleased, no deliverables' do
      before do
        @assignment = unreleased_exam
        assert_equal false, unreleased_exam.published?
        assert_equal false, unreleased_exam.grades_published?
        assert_empty unreleased_exam.deliverables
      end

      it 'returns nil' do
        assert_nil publish_grades_confirmation(@assignment)
      end
    end

    describe 'assignment unreleased, deliverables exist' do
      before do
        @assignment = unreleased_assignment
        assert_equal false, unreleased_assignment.published?
        assert_equal false, unreleased_assignment.grades_published?
        assert_not_empty unreleased_assignment.deliverables
      end

      it 'returns a confirmation message' do
        assert_match /Continue\?/, publish_grades_confirmation(@assignment)
      end
    end
  end
end
