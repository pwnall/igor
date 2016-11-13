class CreateAnalyzers < ActiveRecord::Migration[4.2]
  def change
    create_table :analyzers do |t|
      t.references :deliverable, null: false, unique: true
      t.string :type, limit: 32, null: false
      t.boolean :auto_grading, null: false

      t.text :exec_limits, null: true
      t.file_blob :file, null: true, mime_type_limit: 64, file_name_limit: 256

      t.string :message_name, limit: 64, null: true

      t.timestamps null: false
    end
  end
end
