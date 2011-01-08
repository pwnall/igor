# == Schema Information
# Schema version: 20100504203833
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

# A bunch of work that results in with grades for registered students.
class Course < ActiveRecord::Base
  # The course number (e.g. "6.006")
  validates :number, :length => 1..16, :presence => true
  # The course title (e.g. "Introoduction to Algorithms").
  validates :title, :length => 1..256, :presence => true
  # The contact e-mail for course staff.
  validates :email, :length => 1..64, :presence => true
  # True if the course has recitation sections.
  validates :has_recitations, :inclusion => { :in => [true, false] },
                              :presence => true
  
  # The Google Analytics account ID for the course.
  validates :ga_account, :length => 1..32, :presence => true
  
  # The student registrations for this course.
  has_many :registrations, :dependent => :destroy

  # The main (and only) course on the website.
  def self.main
    first
  end
end
