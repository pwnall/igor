require 'test_helper'

class AssignmentsHelperTest < ActionView::TestCase
  include AssignmentsHelper

  let(:unreleased_exam) { assignments(:main_exam) }
  let(:unreleased_assignment) { assignments(:project) }
  let(:released_assignment) { assignments(:ps2) }
  let(:undecided_exam) { assignments(:main_exam_2) }
  let(:grades_unreleased_assignment) { assignments(:ps3) }
  let(:many_deliverables_assignment) { assignments(:assessment) }
  let(:many_metrics_assignment) { assignments(:assessment) }
  let(:exam_without_deliverables) { assignments(:main_exam_2) }

  let(:deliverable) { deliverables(:assessment_writeup) }

  let(:gradeless_metric) { assignment_metrics(:ps3_p1) }
  let(:weighted_metric) { assignment_metrics(:assessment_overall) }
  let(:checkoff_metric) { assignment_metrics(:assessment_quality) }

  describe '#average_score_fraction_tag' do
    it 'displays placeholder dashes if the assignment has no metrics' do
      assert_empty unreleased_exam.metrics
      render text: average_score_fraction_tag(unreleased_exam)
      assert_select 'span.score', '-'
      assert_select 'span.max-score', '-'
    end

    it 'displays a fraction equivalent to 0 if metrics exist, but no grades
        have been issued for the assignment' do
      assert_not_empty grades_unreleased_assignment.metrics
      assert_empty grades_unreleased_assignment.grades
      render text: average_score_fraction_tag(grades_unreleased_assignment)
      assert_select 'span.score', '0.00'
      assert_select 'span.max-score', '100.00'
    end

    it 'displays the average assignment score, when grades have been issued' do
      assert_not_empty many_metrics_assignment.grades
      render text: average_score_fraction_tag(many_metrics_assignment)
      assert_select 'span.score', '60.00'
      assert_select 'span.max-score', '100.00'
    end

    it 'displays the average assignment score within a section' do
      render text: average_score_fraction_tag(assignments(:assessment),
                                              recitation_sections(:r01))
      assert_select 'span.score', '40.00'
      assert_select 'span.max-score', '100.00'
    end

    it 'displays a fraction equivalent to 0, if the metric has no grades' do
      assert_empty gradeless_metric.grades
      render text: average_score_fraction_tag(gradeless_metric)
      assert_select 'span.score', '0.00'
      assert_select 'span.max-score', '10.00'
    end

    it 'displays the average score for metrics with non-zero weights' do
      assert_not_equal 0, weighted_metric.weight
      render text: average_score_fraction_tag(weighted_metric)
      assert_select 'span.score', '60.00'
      assert_select 'span.max-score', '100.00'
    end

    it 'displays the average score for metrics with zero weight' do
      assert_equal 0, checkoff_metric.weight
      render text: average_score_fraction_tag(checkoff_metric)
      assert_select 'span.score', '7.20'
      assert_select 'span.max-score', '10.00'
    end
  end

  describe '#grading_process_fraction_tag' do
    describe 'for an Assignment' do
      it 'displays a fraction equivalent to 0, if there are no grades' do
        assert_not_empty grades_unreleased_assignment.metrics
        assert_empty grades_unreleased_assignment.grades
        render text: grading_process_fraction_tag(grades_unreleased_assignment)
        assert_select 'span.current-count', '0'
        assert_select 'span.max-count', '4'
      end

      it 'displays the fraction of issued grades, if grades have been issued' do
        assert_not_empty many_metrics_assignment.grades
        render text: grading_process_fraction_tag(many_metrics_assignment)
        assert_select 'span.current-count', '6'
        assert_select 'span.max-count', '8'  # 4 students * 2 metrics
      end
    end

    describe 'for an AssignmentMetric' do
      it 'displays a fraction equivalent to 0, if there are no grades' do
        assert_empty gradeless_metric.grades
        render text: grading_process_fraction_tag(gradeless_metric)
        assert_select 'span.current-count', '0'
        assert_select 'span.max-count', '4'
      end

      it 'displays the fraction of issued grades, if grades have been issued' do
        render text: grading_process_fraction_tag(weighted_metric)
        assert_select 'span.current-count', '3'
        assert_select 'span.max-count', '4'
      end
    end
  end

  describe '#submission_count_fraction_tag' do
    describe 'for an Assignment' do
      it 'displays placeholder dashes if there are no deliverables' do
        assert_empty exam_without_deliverables.deliverables
        render text: submission_count_fraction_tag(exam_without_deliverables)
        assert_select 'span.current-count', '-'
        assert_select 'span.max-count', '-'
      end

      it 'displays the fraction of expected submissions' do
        render text: submission_count_fraction_tag(many_metrics_assignment)
        assert_select 'span.current-count', '3'
        assert_select 'span.max-count', '8'  # 4 students * 2 deliverables
      end
    end

    describe 'for a Deliverable' do
      it 'displays the fraction of expected submissions' do
        render text: submission_count_fraction_tag(deliverable)
        assert_select 'span.current-count', '2'
        assert_select 'span.max-count', '4'
      end
    end
  end

  describe '#grading_progress_tag' do
    it 'returns a blank string if the assignment has no metrics' do
      assert_empty unreleased_exam.metrics
      assert_equal '', grading_progress_tag(unreleased_exam)
    end

    it 'returns an empty meter for assignments with metrics, but no grades' do
      assert_not_empty grades_unreleased_assignment.metrics
      assert_empty grades_unreleased_assignment.grades
      render text: grading_progress_tag(grades_unreleased_assignment)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns an empty meter for metrics with no grades' do
      assert_empty gradeless_metric.grades
      render text: grading_progress_tag(gradeless_metric)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns a meter with the percentage of grades issued for metrics of the
        assignment' do
      render text: grading_progress_tag(released_assignment)
      # 1 grade / 4 students
      assert_select "span.progress-meter:match('style', ?)", /width: 25.00%;/
    end

    it 'returns a meter with the percentage of grades issued for the metric' do
      render text: grading_progress_tag(weighted_metric)
      # 3 grades / 4 students
      assert_select "span.progress-meter:match('style', ?)", /width: 75.00%;/
    end
  end

  describe '#average_score_meter_tag' do
    it 'returns a blank string if the assignment has no metrics' do
      assert_empty unreleased_exam.metrics
      assert_equal '', average_score_meter_tag(unreleased_exam)
    end

    it 'returns an empty meter for assignments with metrics, but no grades' do
      assert_not_empty grades_unreleased_assignment.metrics
      assert_empty grades_unreleased_assignment.grades
      render text: average_score_meter_tag(grades_unreleased_assignment)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns an empty meter for metrics with no grades' do
      assert_empty gradeless_metric.grades
      render text: average_score_meter_tag(gradeless_metric)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns a meter with the average final grade for the assignment' do
      render text: average_score_meter_tag(many_metrics_assignment)
      assert_select "span.progress-meter:match('style', ?)", /width: 60.00%;/
    end

    it 'returns a meter with the average score for zero-weighted metrics' do
      assert_equal 0, checkoff_metric.weight
      render text: average_score_meter_tag(checkoff_metric)
      assert_select "span.progress-meter:match('style', ?)", /width: 72.00%;/
    end

    it 'returns a meter with the average score for non-zero-weighted metrics' do
      assert_not_equal 0, weighted_metric.weight
      render text: average_score_meter_tag(weighted_metric)
      assert_select "span.progress-meter:match('style', ?)", /width: 60.00%;/
    end
  end

  describe '#recitation_score_meter_tag' do
    let(:section) { recitation_sections(:r01) }

    it 'returns an empty meter if the assignment has no metrics' do
      assert_empty unreleased_exam.metrics
      render text: recitation_score_meter_tag(unreleased_exam, section)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns an empty meter for assignments with metrics, but no grades' do
      assert_not_empty grades_unreleased_assignment.metrics
      assert_empty grades_unreleased_assignment.grades
      render text: recitation_score_meter_tag(grades_unreleased_assignment,
                                              section)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns an empty meter for recitation sections with no students' do
      section.users.each do |u|
        u.registration_for(section.course).update! recitation_section: nil
      end
      render text: recitation_score_meter_tag(grades_unreleased_assignment,
                                              section)
      assert_select "span.progress-meter:match('style', ?)", /width: 0.00%;/
    end

    it 'returns a meter with the average recitation score' do
      html_text = recitation_score_meter_tag(many_metrics_assignment, section)
      html = render text: html_text
      puts html
      assert_select "span.progress-meter:match('style', ?)", /width: 40.00%;/
    end
  end

  describe '#submission_count_meter_tag' do
    it 'returns a blank string if the assignment has no deliverables' do
      assert_empty unreleased_exam.metrics
      assert_equal '', submission_count_meter_tag(exam_without_deliverables)
    end

    it 'returns a meter with the fraction of expected submissions across all
        deliverables for an assignment' do
      render text: submission_count_meter_tag(many_deliverables_assignment)
      assert_select "span.progress-meter:match('style', ?)", /width: 37.50%;/  # 3/8
    end

    it 'returns a meter with the fraction of expected submissions for a single
        deliverable' do
      render text: submission_count_meter_tag(deliverable)
      assert_select "span.progress-meter:match('style', ?)", /width: 50.00%;/  # 2/4
    end
  end

  describe '#progress_meter_tag' do
    it 'returns HTML for a progress meter with the given percentage' do
      render text: progress_meter_tag('25%')
      assert_select 'div.progress' do
        assert_select "span.progress-meter:match('style', ?)", /width: 25%;/ do
          assert_select 'p.progress-meter-text', '25%'
        end
      end
    end
  end

  describe '#unrelease_confirmation' do
    describe 'assignment released, grades unreleased' do
      before do
        @assignment = many_metrics_assignment
        assert_equal true, @assignment.released?
        assert_equal false, @assignment.grades_released?
      end

      it 'returns nil' do
        assert_nil unrelease_confirmation(@assignment)
      end
    end

    describe 'assignment released, grades released' do
      before do
        @assignment = released_assignment
        assert_equal true, @assignment.released?
        assert_equal true, @assignment.grades_released?
        assert_not_empty @assignment.grades
      end

      it 'returns a confirmation message' do
        assert_match /Continue\?/, unrelease_confirmation(@assignment)
      end
    end
  end

  describe '#release_grades_confirmation' do
    describe 'assignment released, grades unreleased' do
      before do
        @assignment = many_metrics_assignment
        assert_equal true, @assignment.released?
        assert_equal false, @assignment.grades_released?
      end

      it 'returns nil' do
        assert_nil unrelease_confirmation(@assignment)
      end
    end

    describe 'assignment unreleased, no deliverables' do
      before do
        @assignment = exam_without_deliverables
        assert_equal false, @assignment.released?
        assert_equal false, @assignment.grades_released?
        assert_empty @assignment.deliverables
      end

      it 'returns nil' do
        assert_nil release_grades_confirmation(@assignment)
      end
    end

    describe 'assignment unreleased, deliverables exist' do
      before do
        @assignment = unreleased_assignment
        assert_equal false, @assignment.released?
        assert_equal false, @assignment.grades_released?
        assert_not_empty @assignment.deliverables
      end

      it 'returns a confirmation message' do
        assert_match /Continue\?/, release_grades_confirmation(@assignment)
      end
    end
  end

  describe '#released_at_with_default' do
    let(:file) { assignment_files(:ps1_solutions) }
    let(:current_hour) do
      Time.current.beginning_of_hour.to_s(:datetime_local_field)
    end

    it 'formats the release date of an Assignment' do
      assert_not_nil released_assignment.released_at
      golden = released_assignment.released_at.to_s(:datetime_local_field)
      assert_equal golden, released_at_with_default(released_assignment)
    end

    it 'formats the current hour, if the assignment has a nil release date' do
      assert_nil undecided_exam.released_at
      assert_equal current_hour, released_at_with_default(undecided_exam)
    end

    it 'formats the release date of an AssignmentFile' do
      assert_not_nil file.released_at
      golden = file.released_at.to_s(:datetime_local_field)
      assert_equal golden, released_at_with_default(file)
    end

    it "formats the release date of the file's assignment if only the file's
        release date is nil" do
      assert_not_nil released_assignment.released_at
      new_file = released_assignment.files.new
      golden = released_assignment.released_at.to_s(:datetime_local_field)
      assert_equal golden, released_at_with_default(released_assignment)
    end

    it 'formats the current hour, if both the file and its assignment have nil
        release dates' do
      assert_nil undecided_exam.released_at
      new_file = undecided_exam.files.new
      assert_equal current_hour, released_at_with_default(new_file)
    end
  end
end
