class RenameStudentInfoToRegistration < ActiveRecord::Migration
  def self.up
    rename_table :student_infos, :registrations
    add_column :registrations, :dropped, :boolean, :null => false,
                                                   :default => false
    add_column :registrations, :course_id, :integer, :null => true
    rename_column :registrations, :wants_credit, :for_credit
    rename_column :prerequisite_answers, :student_info_id, :registration_id
    rename_column :recitation_conflicts, :student_info_id, :registration_id

    Registration.all.each do |registration|
      registration.course = Course.main
      registration.save!     
    end    
    change_column :registrations, :course_id, :integer, :null => false
  end

  def self.down
    rename_column :recitation_conflicts, :registration_id, :student_info_id
    rename_column :prerequisite_answers, :registration_id, :student_info_id
    rename_column :registrations, :for_credit, :wants_credit
    remove_column :registrations, :dropped
    remove_column :registrations, :course_id
    rename_table :registrations, :student_infos
  end
end
