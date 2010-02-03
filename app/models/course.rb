# A course is bunch of work that ends up with grades for registered students.
class Course < ActiveRecord::Base
  # The course number (e.g. "6.006")
  validates_length_of :number, :in => 1..16, :allow_nil => false
  # The course title (e.g. "Introoduction to Algorithms").
  validates_length_of :title, :in => 1..256, :allow_nil => false

  # The main (and only) course on the website.
  def self.main
    first
  end
end
