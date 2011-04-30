# == Schema Information
# Schema version: 20110429122654
#
# Table name: db_files
#
#  id             :integer(4)      not null, primary key
#  f_file_name    :text            default(""), not null
#  f_content_type :string(255)     not null
#  f_file_size    :integer(4)      not null
#  f_file         :binary(21474836 default(""), not null
#

# Stores all database-backed files.
class DbFile < ActiveRecord::Base
  has_attached_file :f, :storage => :database
  validates_attachment_presence :f
  validates_attachment_size :f, :less_than => 16.megabytes
  
  default_scope select([:f_file_name, :f_content_type, :f_file_size])
end
