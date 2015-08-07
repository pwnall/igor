require 'test_helper'

class AssignmentFeedbackTest < ActiveSupport::TestCase
  describe '.find_subject' do
    it 'returns the user with the given external id' do
      assert_equal users(:dexter),
          AssignmentFeedback.find_subject('User', users(:dexter).to_param)
    end

    it 'returns the team with the given id' do
      assert_equal teams(:awesome_pset),
          AssignmentFeedback.find_subject('Team', teams(:awesome_pset).to_param)
    end

    it 'returns nil if the requested type is unrecognized' do
      assert_nil AssignmentFeedback.find_subject('Profile',
                                                 profiles(:dexter).to_param)
    end

    it 'returns nil if no User with the given exuid exists' do
      deleted_exuid = users(:dexter).to_param
      users(:dexter).destroy
      assert_nil AssignmentFeedback.find_subject('User', deleted_exuid)
    end

    it 'returns nil if no Team with the given id exists' do
      deleted_id = teams(:awesome_pset).id
      teams(:awesome_pset).destroy
      assert_nil AssignmentFeedback.find_subject('Team', deleted_id)
    end
  end
end
