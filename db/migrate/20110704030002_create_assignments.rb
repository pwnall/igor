class CreateAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :assignments do |t|
      t.references :course, null: false
      t.references :author, null: false
      t.string :name, limit: 64, null: false
      t.boolean :scheduled, null: false
      t.datetime :released_at, null: true
      t.boolean :grades_released, null: false
      t.decimal :weight, precision: 16, scale: 8, null: false
      t.references :team_partition, null: true

      t.timestamps null: false

      t.index [:course_id, :released_at, :name], unique: true
      t.index [:course_id, :name], unique: true
    end
  end
end
