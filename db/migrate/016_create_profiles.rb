class CreateProfiles < ActiveRecord::Migration 
  def self.up
    create_table :profiles do |t|
      # the user that the profile is tied to
      t.integer :user_id, :null => false
      # the real-life full name of the user
      t.string :real_name, :null => false, :limit => 128
      # the way the user prefers to be called
      t.string :nickname, :null => false, :limit => 64
      # the year of the user (1,2,3,4,G ?)
      t.string :year, :null => false
      # the primary Athena account of the user
      t.string :athena_username, :null => false, :limit => 16
      # self-description that the site admins can see
      t.string :about_me, :null => false, :default => '', :limit => 4.kilobytes
      
      # true if the user will use a phone to contact us
      t.boolean :has_phone, :null => false, :default => true
      # the phone number listed as contact
      t.string :phone_number, :limit => 64
      # true if the user will use AIM to contact us
      t.boolean :has_aim, :null => false, :default => false
      # the AIM screen name listed as contact
      t.string :aim_name, :limit => 64
      # true if the user will use Jabber to contact us
      t.boolean :has_jabber, :null => false, :default => false
      # the Jabber screen name listed as contact
      t.string :jabber_name, :limit => 64
      
      # the recitation section that the user belongs to
      t.integer :recitation_section_id, :null => true

      # auditing goodness
      t.timestamps
    end
    
    # Ensure no user gets two profiles.
    add_index :profiles, :user_id, :unique => true
  end

  def self.down
    drop_index :profiles, :user_id
    drop_table :profiles
  end
end
