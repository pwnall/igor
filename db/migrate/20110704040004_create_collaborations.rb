class CreateCollaborations < ActiveRecord::Migration
  def change
    create_table :collaborations do |t|
      t.references :submission, foreign_key: true, null: false
      t.references :collaborator, null: false

      t.index [:submission_id, :collaborator_id], unique: true
    end
  end
end
