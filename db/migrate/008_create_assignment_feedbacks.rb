class CreateAssignmentFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :assignment_feedbacks do |t|
      t.integer :user_id, :null => false
      t.integer :assignment_id, :null => false
      
      t.timestamps
    end
    add_index :assignment_feedbacks, [:user_id, :assignment_id], :unique => true
    add_index :assignment_feedbacks, :assignment_id
  end

  def self.down
    drop_table :assignment_feedbacks
  end
end
