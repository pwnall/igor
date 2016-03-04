class CreateRecitationConflicts < ActiveRecord::Migration[4.2]
  def change
    create_table :recitation_conflicts do |t|
      t.references :registration, null: false
      t.references :time_slot, null: false
      t.string :class_name, null: false

      t.index [:registration_id, :time_slot_id], unique: true
    end
  end
end
