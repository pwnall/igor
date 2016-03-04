class CreateDeadlines < ActiveRecord::Migration[4.2]
  def change
    create_table :deadlines do |t|
      t.references :subject, polymorphic: true, index: { unique: true },
          null: false
      t.datetime :due_at, null: false
      # Get all deadlines for a course.
      t.references :course, index: true, null: false
    end
  end
end
