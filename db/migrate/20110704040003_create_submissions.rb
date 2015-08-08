class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.references :deliverable, null: false
      t.references :db_file, index: { unique: true }, null: false
      t.references :subject, polymorphic: true, null: false

      t.timestamps

      t.index [:subject_id, :subject_type, :deliverable_id], unique: false,
          name: 'index_submissions_on_subject_id_and_type_and_deliverable_id'
      t.index [:deliverable_id, :updated_at], unique: false
      t.index :updated_at, unique: false
    end
  end
end