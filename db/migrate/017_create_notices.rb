class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      # the subject of the notice
      t.string :subject, :limit => 128, :null => false
      # the contents of the notice
      t.string :contents, :limit => 8.kilobytes, :null => false
      # how many users the notice has been posted to
      t.integer :posted_count, :null => false, :default => 0
      # how many users have seen the notice
      t.integer :seen_count, :null => false, :default => 0
      # how many users have dismissed the notice
      t.integer :dismissed_count, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
