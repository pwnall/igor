class CreateNoticeStatuses < ActiveRecord::Migration
  def self.up
    create_table :notice_statuses do |t|
      # the notice that this status is for
      t.integer :notice_id, :null => false
      # the user that this status is for
      t.integer :user_id, :null => false
      # if true, the user has seen the notice
      t.boolean :seen, :null => false, :default => false
    end
    
    # Retrieve all the notices for a user.
    add_index :notice_statuses, [:user_id, :notice_id], :null => false,
                                :unique => true
                                
    # Show how many users received a notice.
    add_index :notice_statuses, [:notice_id, :user_id], :null => false,
                                :unique => true
  end

  def self.down
    drop_table :notice_statuses
  end
end
