class CreateProfilePhotos < ActiveRecord::Migration
  def change
    create_table :profile_photos do |t|
      t.references :profile, null: false
      
      t.string :pic_file_name, limit: 256, null: false
      t.string :pic_content_type, limit: 64, null: false
      t.integer :pic_file_size, null: false
      t.binary :pic_file, limit: 1.megabyte, null: false
      t.binary :pic_profile_file, limit: 1.megabyte, null: false
      t.binary :pic_thumb_file, limit: 1.megabyte, null: false

      t.timestamps
    end
    
    add_index :profile_photos, :profile_id, unique: true
  end
end
