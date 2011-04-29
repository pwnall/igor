class CreateDbFiles < ActiveRecord::Migration
  def self.up
    create_table :db_files do |t|
      t.text :f_file_name, :length => 256, :null => false
      t.string :f_content_type, :length => 64, :null => false
      t.integer :f_file_size, :null => false
      t.binary :f_file, :limit => 16.megabytes, :null => false
    end
  end

  def self.down
    drop_table :db_files
  end
end
