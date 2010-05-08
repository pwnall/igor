class CreateNoticeStatuses < ActiveRecord::Migration
  def self.up
    create_table :notice_statuses do |t|
      t.integer :announcement_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :seen, :null => false, :default => false
    end
    
    # Retrieve all the notices for a user.
    add_index :notice_statuses, [:user_id, :announcement_id], :null => false,
                                :unique => true                                
  end

  def self.down
    drop_table :notice_statuses
  end
end
