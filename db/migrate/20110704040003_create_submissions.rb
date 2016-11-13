class CreateSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :submissions do |t|
      t.references :deliverable, null: false
      t.file_blob :file, null: false, mime_type_limit: 64, file_name_limit: 256
      t.references :subject, polymorphic: true, null: false
      t.references :uploader, null: false
      t.string :upload_ip, limit: 48, null: false

      t.timestamps null: false

      t.index [:subject_id, :subject_type, :deliverable_id], unique: false,
          name: 'index_submissions_on_subject_id_and_type_and_deliverable_id'
      t.index [:deliverable_id, :updated_at], unique: false
      t.index :updated_at, unique: false
    end
  end
end
