require 'digest/sha2'

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :password_salt, :limit => 16, :null => false
      t.string :password_hash, :limit => 64, :null => false
      t.string :email, :limit => 64, :null => false
      t.boolean :active, :null => false, :default => false
      t.boolean :admin, :null => false, :default => false
      
      t.timestamps
    end

    # Login and password recovery: find a user by e-mail address.
    add_index :users, :email, :unique => true, :null => false
  end
end
