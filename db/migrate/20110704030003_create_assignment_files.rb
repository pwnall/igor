class CreateAssignmentFiles < ActiveRecord::Migration
  def change
    create_table :assignment_files do |t|
      t.string :description, limit: 64, null: false
      t.references :assignment, index: true, foreign_key: true, null: false
      t.references :db_file, index: { unique: true }, foreign_key: true,
                             null: false
      t.datetime :released_at, null: true

      t.timestamps null: false
    end
  end
end
