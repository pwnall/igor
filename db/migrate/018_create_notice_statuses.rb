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
  end

  def self.down
    drop_table :notice_statuses
  end
end
