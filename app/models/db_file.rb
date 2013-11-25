# == Schema Information
#
# Table name: db_files
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  f_file_name    :string(255)
#  f_content_type :string(255)
#  f_file_size    :integer
#  f_updated_at   :datetime
#

# Stores all database-backed files.
class DbFile < ActiveRecord::Base
  has_attached_file :f, storage: :database, database_table: :db_file_blobs
  validates_attachment_presence :f
  validates_attachment_size :f, less_than: 16.megabytes
end
