class CreateAnalyzers < ActiveRecord::Migration
  def change
    create_table :analyzers do |t|
      t.references :deliverable, null: false, unique: true
      t.string :type, limit: 32, null: false
      t.boolean :auto_grading, null: false

      t.text :exec_limits, limit: 1.kilobyte, null: true
      t.references :db_file, null: true

      t.string :message_name, limit: 64, null: true

      t.timestamps
    end
  end
end
