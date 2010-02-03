class CreateStudentInfos < ActiveRecord::Migration
  def self.up
    create_table :student_infos do |t|
      t.integer :user_id, :null => false
      t.boolean :wants_credit, :null => false
      t.string :motivation, :limit => 32.kilobytes

      t.timestamps
    end
    
    add_index :student_infos, :user_id, :unique => true
  end

  def self.down
    drop_table :student_infos
  end
end
