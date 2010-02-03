class CreateStudentInfos < ActiveRecord::Migration
  def self.up
    create_table :student_infos do |t|
      # the user that the student info is tied to
      t.integer :user_id, :null => false
      # taking the class for credit ?
      t.boolean :wants_credit, :null => false
      # has taken 6.01 ?
      t.boolean :has_python, :null => false
      # has taken 6.042 / 18.062? ?
      t.boolean :has_math, :null => false
      # previous python experience (if hasn't taken 6.01)
      t.string :python_experience, :limit => 4.kilobytes
      # previous math experience (if hasn't taken 6.042)
      t.string :math_experience, :limit => 4.kilobytes
      # comments
      t.string :comments, :limit => 32.kilobytes

      # handy to have for late modifications, etc.
      t.timestamps
    end
    
    add_index :student_infos, :user_id, :unique => true
  end

  def self.down
    remove_index :student_infos, :user_id
    drop_table :student_infos
  end
end
