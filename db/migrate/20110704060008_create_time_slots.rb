class CreateTimeSlots < ActiveRecord::Migration[4.2]
  def change
    create_table :time_slots do |t|
      t.references :course, null: false
      t.integer :day, limit: 1, null: false
      t.integer :starts_at, limit: 4, null: false
      t.integer :ends_at, limit: 4, null: false

      t.index [:course_id, :day, :starts_at, :ends_at], unique: true
    end
  end
end
