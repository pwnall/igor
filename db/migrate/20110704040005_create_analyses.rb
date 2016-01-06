class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.references :submission, null: false
      t.integer :status_code, null: false

      t.text :log, limit: 64.kilobytes, null: false
      t.text :private_log, limit: 64.kilobytes, null: false
      t.text :scores, limit: 16.kilobytes, null: true

      t.timestamps null: false

      t.index :submission_id, unique: true
    end
  end
end
