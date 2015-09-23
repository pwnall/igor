require 'test_helper'

class UploadingSubmissionsTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    @deliverable = deliverables(:assessment_code)
    @current_user = users(:mandark)
    assert_equal true, @deliverable.assignment.can_submit?(@current_user)
    assert_equal 1, (@current_user.registered_courses.count +
        @current_user.staff_courses.count)
  end

  let(:submissions_selector) { "li#deliverable-#{@deliverable.to_param}" }
  let(:analysis_status_selector) do
    "#{submissions_selector} .submission-result a"
  end

  describe 'upload your first submission' do
    describe 'deliverable auto-grades via Docker' do
      it 'updates the submission to reflect an :ok analysis status' do
        log_in_as @current_user

        visit "/6.006/assignments/#{@deliverable.assignment.to_param}"
        assert_equal true, has_css?("#{submissions_selector} .no-submission")

        within submissions_selector do
          attach_file 'submission_db_file_attributes_f',
                      'test/fixtures/files/submission/good_fib.py'
          click_button 'Submit'
        end

        assert_equal true, has_css?("#{analysis_status_selector}.queued")
        Delayed::Worker.new.work_off
        wait_for_selector("#{analysis_status_selector}.ok") {
          assert_equal true, has_css?("#{analysis_status_selector}.ok")
        }
      end
    end
  end
end
