class CreateMainCourse < ActiveRecord::Migration
  def up
    # Pre-populate with 6.006, since this is the course that founded the site.
    Course.create! :number => '6.006',
                   :title => 'Introduction to Algorithms',
                   :email => '6.006-tas@mit.edu',
                   :has_recitations => true,
                   :ga_account => 'UA-2624215-2'
  end

  def down
    Course.main && Course.main.destroy
  end
end
