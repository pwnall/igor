class CreateFileBlobs < ActiveRecord::Migration[5.0]
  def change
    create_file_blobs_table :file_blobs, blob_limit: 128.megabytes do |t|
      # Build any custom table structure here.
    end
  end
end
