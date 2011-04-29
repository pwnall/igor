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

require 'spec_helper'

describe DbFile do
  pending "add some examples to (or delete) #{__FILE__}"
end
