# == Schema Information
# Schema version: 20100208065707
#
# Table name: assignment_feedbacks
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  assignment_id :integer(4)      not null
#  hours         :float           not null
#  difficulty    :integer(4)      not null
#  coding_quant  :integer(4)      not null
#  theory_quant  :integer(4)      not null
#  comments      :string(4096)
#  created_at    :datetime
#  updated_at    :datetime
#

class AssignmentFeedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment
  
  @@difficulty_levels = ['Way too easy', 'Too easy', 'A bit too easy', 'Good', 'A bit too hard', 'Too hard', 'Way too hard']
  @@quant_levels = ['Too little', 'Good', 'Too much']
  
  @@difficulty_levels_hash = Hash[*((1..(@@difficulty_levels.length)).zip(@@difficulty_levels).flatten)]
  @@quant_levels_hash = Hash[*((1..(@@quant_levels.length)).zip(@@quant_levels).flatten)]
    
  def self.difficulty_levels_hash
    @@difficulty_levels_hash
  end
  
  def self.quant_levels_hash
    @@quant_levels_hash
  end
  
  def difficulty_str
    @@difficulty_levels_hash[self.difficulty]
  end
  
  def theory_quant_str
    @@quant_levels_hash[self.theory_quant]
  end

  def coding_quant_str
    @@quant_levels_hash[self.coding_quant]
  end
end
