# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  inviter_id :integer
#  invitee_id :integer
#  team_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Invitation do
  pending "add some examples to (or delete) #{__FILE__}"
end
