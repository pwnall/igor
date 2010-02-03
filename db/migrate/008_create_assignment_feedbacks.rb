class CreateAssignmentFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :assignment_feedbacks do |t|
      # the user submitting the feedback
      t.integer :user_id, :null => false
      # the assignment that the feedback is submitted for
      t.integer :assignment_id, :null => false
      
      # hours spent on the pset
      t.float :hours, :null => false
      # difficulty level (1-7)
      t.integer :difficulty, :null => false
      # how much coding (1-3)
      t.integer :coding_quant, :null => false
      # how much theory (1-3)
      t.integer :theory_quant, :null => false
      # general comments
      t.string :comments, :limit => 4.kilobytes

      t.timestamps
    end
    add_index :assignment_feedbacks, [:user_id, :assignment_id], :unique => true
    add_index :assignment_feedbacks, :assignment_id
  end

  def self.down
    drop_table :assignment_feedbacks
  end
end
