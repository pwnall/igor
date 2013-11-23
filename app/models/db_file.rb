# == Schema Information
#
# Table name: db_files
#
#  id             :integer          not null, primary key
#  f_file_name    :text             default(""), not null
#  f_content_type :string(255)      not null
#  f_file_size    :integer          not null
#  f_file         :binary(214748364 default(""), not null
#

# Stores all database-backed files.
class DbFile < ActiveRecord::Base
  has_attached_file :f, storage: :database, database_table: :db_file_blobs
  validates_attachment_presence :f
  validates_attachment_size :f, less_than: 16.megabytes
end
