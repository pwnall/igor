class CreateDbFileBlobs < ActiveRecord::Migration[4.2]
  def change
    create_table :db_file_blobs do |t|
      t.references :db_file, null: false
      t.string :style, limit: 16
      t.binary :file_contents, limit: 128.megabytes

      t.index [:db_file_id, :style], unique: true
    end
  end
end
