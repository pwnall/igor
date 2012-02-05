class CreateProfiles < ActiveRecord::Migration 
  def change
    create_table :profiles do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false, :limit => 128
      t.string :nickname, :null => false, :limit => 64
      t.string :university, :null => false, :limit => 64
      t.string :department, :null => false, :limit => 64
      t.string :year, :null => false, :limit => 4
      t.string :athena_username, :null => false, :limit => 32
      t.string :about_me, :null => false, :default => '', :limit => 4.kilobytes
      
      t.timestamps
    end
    
    add_index :profiles, :user_id, :unique => true
  end
end
