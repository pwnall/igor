class CreateRecitationConflicts < ActiveRecord::Migration
  def change
    create_table :recitation_conflicts do |t|
      t.references :registration, null: false
      t.integer :timeslot, null: false
      t.string :class_name, null: false
    end
    add_index :recitation_conflicts, [:registration_id, :timeslot],
                                     unique: true
  end
end
