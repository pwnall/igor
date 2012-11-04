# == Schema Information
#
# Table name: surveys
#
#  id         :integer          not null, primary key
#  name       :string(128)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Survey do
  fixtures :surveys, :survey_questions
  
  let(:troubleshooting) { surveys(:psets) }
  let(:so_it_seems_we_care) { surveys(:projects) }
  
  describe 'questions' do
    it 'should not use questions from other surveys' do
      troubleshooting.should have(5).questions
      so_it_seems_we_care.should have(1).question
    end
  end
end
