class CreateTimeSlotAllotments < ActiveRecord::Migration
  def change
    create_table :time_slot_allotments do |t|
      t.references :time_slot, index: true, foreign_key: true, null: false
      t.references :recitation_section, index: true, foreign_key: true,
          null: false

      t.index [:recitation_section_id, :time_slot_id], unique: true,
          name: 'index_time_slot_allotments_on_recitation_section_and_time_slot'
    end
  end
end
