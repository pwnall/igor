class CreateAssignmentFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :assignment_files do |t|
      t.string :description, limit: 64, null: false
      t.references :assignment, index: true, foreign_key: true, null: false
      t.file_blob :file, null: false, mime_type_limit: 64, file_name_limit: 256
      t.datetime :released_at, null: true

      t.timestamps null: false
    end
  end
end
