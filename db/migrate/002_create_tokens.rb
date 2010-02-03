class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.integer :user_id, :null => false
      t.string :token, :limit => 64, :null => false
      t.string :action, :limit => 32, :null => false
      t.string :argument, :limit => 1.kilobyte
      
      t.datetime :created_at
    end
    
    # find the token by its content
    add_index :tokens, :token, :unique => true
    # find tokens by their users [and what they do]
    add_index :tokens, [:user_id, :action]
  end

  def self.down
    remove_index :tokens, :token
    drop_table :tokens
  end
end
