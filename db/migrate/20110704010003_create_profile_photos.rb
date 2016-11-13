class CreateProfilePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_photos do |t|
      t.references :profile, null: false,
          index: { unique: true }, foreign_key: true

      t.file_blob :image, null: false, mime_type_limit: 64,
                                       file_name_limit: 256

      t.timestamps
    end
  end
end
