require 'digest/sha2'

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :limit => 64, :null => false
      t.string :password_salt, :limit => 16, :null => false
      t.string :password_hash, :limit => 64, :null => false
      t.string :email, :limit => 64, :null => false
      t.boolean :active, :null => false, :default => false
      t.boolean :admin, :null => false, :default => false
      
      t.timestamps
    end

    # Login: find a user by name.
    add_index :users, :name, :unique => true, :null => false
    # Password recovery: find a user by e-mail address.
    add_index :users, :email, :unique => true, :null => false
  end

  def self.down
    remove_index :users, :email
    remove_index :users, :name
    drop_table :users
  end
end
