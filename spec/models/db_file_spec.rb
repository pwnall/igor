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

require 'spec_helper'

describe DbFile do
  pending "add some examples to (or delete) #{__FILE__}"
end
