class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.references :author, :null => false
      
      t.string :headline, :limit => 128, :null => false
      t.string :contents, :limit => 8.kilobytes, :null => false
      t.boolean :open_to_visitors, :null => false, :default => false

      t.timestamps
    end
  end
end
