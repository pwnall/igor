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

require 'spec_helper'

describe DbFile do
  pending "add some examples to (or delete) #{__FILE__}"
end
