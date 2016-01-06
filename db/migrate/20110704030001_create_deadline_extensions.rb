class CreateDeadlineExtensions < ActiveRecord::Migration
  def change
    create_table :deadline_extensions do |t|
      t.references :subject, polymorphic: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.references :grantor, null: true
      t.datetime :due_at, null: false

      t.timestamps null: false

      t.index [:subject_id, :subject_type, :user_id], unique: true,
          name: 'index_deadline_extensions_on_subject_and_user_id'
    end

    add_foreign_key :deadline_extensions, :users, column: :grantor_id,
        on_delete: :nullify
  end
end
