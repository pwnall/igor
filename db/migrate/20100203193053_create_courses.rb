class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :number, :limit => 16, :null => false
      t.string :title, :limit => 256, :null => false
      t.boolean :has_recitations, :null => false, :default => true

      t.timestamps
    end
    
    # Resolve a course by its number. We might use that in URLs.
    add_index :courses, :number, :unique => :true, :null => false

    # Pre-populate with 6.006, since this is the course that founded the site.
    Course.create :number => '6.006',
                  :title => 'Introduction to Algorithms',
                  :has_recitations => true
  end

  def self.down
    drop_table :courses
  end
end
