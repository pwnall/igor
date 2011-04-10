class CreatePrerequisites < ActiveRecord::Migration
  def self.up
    create_table :prerequisites do |t|
      t.integer :course_id, :null => false
      t.string :prerequisite_number, :limit => 64, :null => false
      t.string :waiver_question, :limit => 256, :null => false

      t.timestamps
    end
    
    add_index :prerequisites, [:course_id, :prerequisite_number],
                              :null => false, :unique => true
  end

  def self.down
    drop_table :prerequisites
  end
end
