class RenameStudentInfoToRegistration < ActiveRecord::Migration
  def self.up
    rename_table :student_infos, :registrations
    add_column :registrations, :dropped, :boolean, :null => false,
                                                   :default => false
    add_column :registrations, :course_id, :integer, :null => true

    Registration.all.each do |registration|
      registration.course = Course.main
      registration.save!     
    end
    
    change_column :registrations, :course_id, :integer, :null => false
  end

  def self.down
    remove_column :registrations, :dropped
    remove_column :registrations, :course_id
    rename_table :registrations, :student_infos
  end
end
