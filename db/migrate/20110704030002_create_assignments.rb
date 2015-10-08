class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :course, null: false
      t.references :author, null: false

      t.references :team_partition, null: true

      t.decimal :weight, precision: 16, scale: 8, null: false

      t.string :name, limit: 64, null: false

      t.boolean :deliverables_ready, null: false
      t.boolean :grades_published, null: false

      t.timestamps

      t.index [:course_id, :name], unique: true
    end
  end
end
