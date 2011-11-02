class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :user_id, :null => false
      t.integer :course_id, :null => false
      t.boolean :dropped, :null => false, :default => false

      t.boolean :for_credit, :null => false, :default => true
      t.boolean :allows_publishing, :null => false, :default => true

      t.integer :recitation_section_id, :null => true

      t.timestamps
    end
    
    add_index :registrations, [:user_id, :course_id], :unique => true,
                                                      :null => false
    add_index :registrations, [:course_id, :user_id], :unique => true,
                                                      :null => false
  end
end
