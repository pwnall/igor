class CreatePhotoBlobs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :photo_blobs do |t|
      t.integer :profile_photo_id, null: false
      t.string :style, limit: 16
      t.binary :file_contents, limit: 1.megabyte, null: false
    end

    change_table :photo_blobs do |t|
      t.index [:profile_photo_id, :style], unique: true
    end
  end

  def self.down
    drop_table :pics
  end
end
