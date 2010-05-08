class CreateAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :announcements do |t|
      t.string :headline, :limit => 128, :null => false
      t.string :contents, :limit => 8.kilobytes, :null => false
      t.integer :author_id, :null => false
      t.boolean :open_to_visitors, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :announcements
  end
end
