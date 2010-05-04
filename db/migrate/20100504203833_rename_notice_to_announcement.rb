class RenameNoticeToAnnouncement < ActiveRecord::Migration
  def self.up
    remove_column :notices, :posted_count
    remove_column :notices, :seen_count
    remove_column :notices, :dismissed_count
    rename_table :notices, :announcements
    rename_column :notice_statuses, :notice_id, :announcement_id
    rename_column :announcements, :subject, :headline
    add_column :announcements, :author_id, :integer
    add_column :announcements, :open_to_visitors, :boolean, :null => false,
                                                            :default => false 
    Announcement.all.each do |announcement|
      announcement.update_attributes! :author => User.first
    end
    change_column :announcements, :author_id, :integer, :null => false
  end

  def self.down
    remove_column :announcements, :open_to_visitors
    remove_column :announcements, :author_id
    rename_column :announcements, :headline, :subject
    rename_column :notice_statuses, :announcement_id, :notice_id
    rename_table :announcements, :notices
    add_column :notices, :posted_count, :integer, :null => false, :default => 0
    add_column :notices, :seen_count, :integer, :null => false, :default => 0
    add_column :notices, :dismissed_count, :integer, :null => false,
                                                     :default => 0
  end
end
