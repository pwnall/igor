# == Schema Information
# Schema version: 20100502201753
#
# Table name: recitation_conflicts
#
#  id              :integer(4)      not null, primary key
#  student_info_id :integer(4)      not null
#  class_name      :string(255)     not null
#  timeslot        :integer(4)      not null
#

class RecitationConflict < ActiveRecord::Base
  belongs_to :student_info
end
