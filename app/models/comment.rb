class Comment < ActiveRecord::Base
  # Each comment belongs to a grade
  belongs_to :grade
  
  attr_accessible :grade_id
  attr_accessible :comment
end
