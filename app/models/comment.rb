class Comment < ActiveRecord::Base
  # Each comment belongs to a grade
  belongs_to :grade
  belongs_to :grader, class_name: 'User'
  validates :grader, presence: true
  
  attr_accessible :grader_id
  attr_accessible :grade_id
  attr_accessible :comment
end
