# == Schema Information
#
# Table name: db_files
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  f_file_name    :string
#  f_content_type :string
#  f_file_size    :integer
#  f_updated_at   :datetime
#

# Stores all database-backed files.
class DbFile < ActiveRecord::Base
  has_attached_file :f, storage: :database, database_table: :db_file_blobs
  # TODO(pwnall): find a way to reject text/html and accept everything else
  validates_attachment :f, presence: true, size: { less_than: 16.megabytes },
      content_type: { content_type: /\A.*\Z/ }
end
