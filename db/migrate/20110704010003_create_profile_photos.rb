class CreateProfilePhotos < ActiveRecord::Migration[4.2]
  def change
    create_table :profile_photos do |t|
      t.references :profile, null: false
      t.timestamps null: false
    end

    add_attachment :profile_photos, :pic

    change_table :profile_photos do |t|
      t.index :profile_id, unique: true
    end
  end
end
