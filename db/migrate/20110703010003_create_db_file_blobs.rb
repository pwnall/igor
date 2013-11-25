class CreateDbFileBlobs < ActiveRecord::Migration
  def self.up
    create_table :db_file_blobs do |t|
      t.integer :db_file_id, null: false
      t.string :style, limit: 16
      t.binary :file_contents, limit: 16.megabytes
    end

    change_table :db_file_blobs do |t|
      t.index [:db_file_id, :style], unique: true
    end
  end

  def self.down
    drop_table :db_file_blobs
  end
end
