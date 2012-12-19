class CreateRecitationStudentAssignment < ActiveRecord::Migration
  def change
    create_table :recitation_student_assignments do |t|
      t.references :recitation_assignment_proposal, :null => false
      t.references :user, :null => false
      t.references :recitation_section
      t.boolean :has_conflict, :null => false
    end
    add_index :recitation_student_assignments, :recitation_assignment_proposal_id, 
              name: 'index_recitation_students_to_proposals'
    add_index :recitation_student_assignments, :user_id
    add_index :recitation_student_assignments, :recitation_section_id
  end
end
