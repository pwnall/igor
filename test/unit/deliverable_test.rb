require File.dirname(__FILE__) + '/../test_helper'

class DeliverableTest < ActiveSupport::TestCase
  def setup
    @deliverable = deliverables(:ps1_writeup)
  end
  
  test "submission_for_user on team" do
    assert_equal submissions(:admin_ps1),
                 @deliverable.submission_for_user(users(:admin)),
                 'Submission for author'
    assert_equal submissions(:admin_ps1),
                 @deliverable.submission_for_user(users(:dexter)),
                 'Submission for teammate'
    assert_equal nil, @deliverable.submission_for_user(users(:inactive)),
                 'Submission for non-submitting team'
  end

  test "submission_for_user without teams" do
    @deliverable = deliverables(:assessment_writeup)
    assert_equal submissions(:admin_assessment),
                 @deliverable.submission_for_user(users(:admin)),
                 'Submission for author'
    assert_equal nil,
                 @deliverable.submission_for_user(users(:inactive)),
                 'Submission for non-submitter'
  end
end
