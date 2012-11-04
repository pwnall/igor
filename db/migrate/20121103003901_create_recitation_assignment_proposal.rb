class CreateRecitationAssignmentProposal < ActiveRecord::Migration
  def change
    create_table :recitation_assignment_proposals do |t|
      t.references :course, :null => false
      t.integer :recitation_size, :null => false
      t.integer :number_of_recitations, :null => false
      t.integer :number_of_conflicts, :null => false

      t.timestamps
    end
  end
end
