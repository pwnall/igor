class CreateProfiles < ActiveRecord::Migration 
  def self.up
    create_table :profiles do |t|
      t.integer :user_id, :null => false
      t.string :real_name, :null => false, :limit => 128
      t.string :nickname, :null => false, :limit => 64
      t.string :university, :null => false, :limit => 64
      t.string :department, :null => false, :limit => 64
      t.string :year, :null => false, :limit => 4
      t.string :athena_username, :null => false, :limit => 32
      t.string :about_me, :null => false, :default => '', :limit => 4.kilobytes
      t.boolean :allows_publishing, :null => false, :default => true
      
      t.boolean :has_phone, :null => false, :default => true
      t.boolean :has_aim, :null => false, :default => false
      t.boolean :has_jabber, :null => false, :default => false
      t.string :phone_number, :limit => 64
      t.string :aim_name, :limit => 64
      t.string :jabber_name, :limit => 64
      
      t.integer :recitation_section_id, :null => true

      t.timestamps
    end
    
    # Ensure no user gets two profiles.
    add_index :profiles, :user_id, :unique => true
  end

  def self.down
    drop_table :profiles
  end
end
