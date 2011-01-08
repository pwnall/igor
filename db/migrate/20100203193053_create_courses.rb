class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :number, :limit => 16, :null => false
      t.string :title, :limit => 256, :null => false      
      t.string :ga_account, :limit => 32, :null => false
      t.string :email, :limit => 64, :null => false
      t.boolean :has_recitations, :null => false, :default => true

      t.timestamps
    end
    
    # Resolve a course by its number. We might use that in URLs.
    add_index :courses, :number, :unique => :true, :null => false

    # Pre-populate with 6.006, since this is the course that founded the site.
    Course.create! :number => '6.006',
                   :title => 'Introduction to Algorithms',
                   :email => '6.006-tas@mit.edu',
                   :has_recitations => true,
                   :ga_account => 'UA-2624215-2'
  end

  def self.down
    drop_table :courses
  end
end
