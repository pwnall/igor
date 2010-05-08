class CreateDeliverableValidations < ActiveRecord::Migration
  def self.up
    create_table :deliverable_validations do |t|
      # Single-Table Inheritance (STI).
      t.string :type, :limit => 128, :null => false
      
      t.integer :deliverable_id, :null => false
      t.string :message_name, :limit => 64
      t.string :pkg_uri, :limit => 1024
      t.string :pkg_tag, :limit => 64
      
      
      t.string :pkg_file_name, :limit => 256
      t.string :pkg_content_type, :limit => 64
      t.integer :pkg_file_size
      t.binary :pkg_file, :limit => 64.megabytes
      
      t.integer :time_limit, :default => nil

      t.timestamps
    end
  end

  def self.down
    drop_table :deliverable_validations
  end
end
