class AmmendPrerequisites < ActiveRecord::Migration
  def self.up
    rename_column :prerequisites, :course_number, :prerequisite_number
    add_column :prerequisites, :course_id, :integer
    
    Prerequisite.all.each do |prereq|
      prereq.course = Course.main
      prereq.save!
    end
    
    change_column :prerequisites, :course_id, :integer, :null => false
    add_index :prerequisites, [:course_id, :prerequisite_number],
                              :null => false, :unique => true
  end

  def self.down
    rename_column :prerequisites, :prerequisite_number, :course_number
    remove_column :prerequisites, :course_id
  end
end
