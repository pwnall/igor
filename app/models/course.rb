# == Schema Information
# Schema version: 20100216020942
#
# Table name: courses
#
#  id              :integer(4)      not null, primary key
#  number          :string(16)      not null
#  title           :string(256)     not null
#  ga_account      :string(32)      not null
#  has_recitations :boolean(1)      default(TRUE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

# A course is bunch of work that ends up with grades for registered students.
class Course < ActiveRecord::Base
  # The course number (e.g. "6.006")
  validates_length_of :number, :in => 1..16, :allow_nil => false
  # The course title (e.g. "Introoduction to Algorithms").
  validates_length_of :title, :in => 1..256, :allow_nil => false
  # True if the course has recitation sections.
  validates_inclusion_of :has_recitations, :in => [true, false]
  
  # The Google Analytics account ID for the course.
  validates_length_of :ga_account, :in => 1..32, :allow_nil => false

  # The main (and only) course on the website.
  def self.main
    first
  end
end
