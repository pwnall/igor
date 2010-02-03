# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100203124712) do

  create_table "assignment_feedbacks", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "assignment_id",                 :null => false
    t.float    "hours",                         :null => false
    t.integer  "difficulty",                    :null => false
    t.integer  "coding_quant",                  :null => false
    t.integer  "theory_quant",                  :null => false
    t.string   "comments",      :limit => 4096
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignment_feedbacks", ["assignment_id"], :name => "index_assignment_feedbacks_on_assignment_id"
  add_index "assignment_feedbacks", ["user_id", "assignment_id"], :name => "index_assignment_feedbacks_on_user_id_and_assignment_id", :unique => true

  create_table "assignment_metrics", :force => true do |t|
    t.string   "name",          :limit => 64,                                                   :null => false
    t.integer  "assignment_id",                                                                 :null => false
    t.integer  "max_score"
    t.boolean  "published",                                                  :default => false
    t.decimal  "weight",                      :precision => 16, :scale => 8, :default => 1.0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", :force => true do |t|
    t.datetime "deadline",                 :null => false
    t.string   "name",       :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deliverable_validations", :force => true do |t|
    t.string   "type",             :limit => 128,        :null => false
    t.integer  "deliverable_id",                         :null => false
    t.string   "message_name",     :limit => 64
    t.string   "pkg_uri",          :limit => 1024
    t.string   "pkg_tag",          :limit => 64
    t.string   "pkg_file_name",    :limit => 256
    t.string   "pkg_content_type", :limit => 64
    t.integer  "pkg_file_size"
    t.binary   "pkg_file",         :limit => 2147483647
    t.binary   "pkg_medium_file"
    t.binary   "pkg_thumb_file"
    t.integer  "time_limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deliverables", :force => true do |t|
    t.integer  "assignment_id",                                    :null => false
    t.string   "name",          :limit => 80,                      :null => false
    t.string   "description",   :limit => 2048,                    :null => false
    t.boolean  "published",                     :default => false, :null => false
    t.string   "filename",      :limit => 256,  :default => "",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deliverables", ["assignment_id"], :name => "index_deliverables_on_assignment_id"

  create_table "grades", :force => true do |t|
    t.integer  "assignment_metric_id"
    t.integer  "user_id"
    t.integer  "grader_user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notice_statuses", :force => true do |t|
    t.integer "notice_id",                    :null => false
    t.integer "user_id",                      :null => false
    t.boolean "seen",      :default => false, :null => false
  end

  add_index "notice_statuses", ["notice_id", "user_id"], :name => "index_notice_statuses_on_notice_id_and_user_id", :unique => true
  add_index "notice_statuses", ["user_id", "notice_id"], :name => "index_notice_statuses_on_user_id_and_notice_id", :unique => true

  create_table "notices", :force => true do |t|
    t.string   "subject",         :limit => 128,                 :null => false
    t.string   "contents",        :limit => 8192,                :null => false
    t.integer  "posted_count",                    :default => 0, :null => false
    t.integer  "seen_count",                      :default => 0, :null => false
    t.integer  "dismissed_count",                 :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prerequisite_answers", :force => true do |t|
    t.integer  "student_info_id", :null => false
    t.integer  "prerequisite_id", :null => false
    t.boolean  "took_course",     :null => false
    t.text     "waiver_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prerequisite_answers", ["student_info_id", "prerequisite_id"], :name => "prerequisites_for_a_student", :unique => true

  create_table "prerequisites", :force => true do |t|
    t.string   "course_number",   :limit => 64,  :null => false
    t.string   "waiver_question", :limit => 256, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",                                                  :null => false
    t.string   "real_name",             :limit => 128,                     :null => false
    t.string   "nickname",              :limit => 64,                      :null => false
    t.string   "year",                                                     :null => false
    t.string   "athena_username",       :limit => 16,                      :null => false
    t.string   "about_me",              :limit => 4096, :default => "",    :null => false
    t.boolean  "has_phone",                             :default => true,  :null => false
    t.string   "phone_number",          :limit => 64
    t.boolean  "has_aim",                               :default => false, :null => false
    t.string   "aim_name",              :limit => 64
    t.boolean  "has_jabber",                            :default => false, :null => false
    t.string   "jabber_name",           :limit => 64
    t.integer  "recitation_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id", :unique => true

  create_table "recitation_conflicts", :force => true do |t|
    t.integer "student_info_id", :null => false
    t.string  "class_name",      :null => false
    t.integer "timeslot",        :null => false
  end

  add_index "recitation_conflicts", ["student_info_id", "timeslot"], :name => "index_recitation_conflicts_on_student_info_id_and_timeslot", :unique => true

  create_table "recitation_sections", :force => true do |t|
    t.integer  "serial",                   :null => false
    t.integer  "leader_id",                :null => false
    t.string   "time",       :limit => 64, :null => false
    t.string   "location",   :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recitation_sections", ["serial"], :name => "index_recitation_sections_on_serial", :unique => true

  create_table "run_results", :force => true do |t|
    t.integer  "submission_id",                     :null => false
    t.integer  "score"
    t.string   "diagnostic",    :limit => 256
    t.binary   "stdout",        :limit => 16777215
    t.binary   "stderr",        :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "run_results", ["submission_id"], :name => "index_run_results_on_submission_id", :unique => true

  create_table "student_infos", :force => true do |t|
    t.integer  "user_id",                          :null => false
    t.boolean  "wants_credit",                     :null => false
    t.text     "comments",     :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_infos", ["user_id"], :name => "index_student_infos_on_user_id", :unique => true

  create_table "submissions", :force => true do |t|
    t.integer  "deliverable_id",                        :null => false
    t.integer  "user_id",                               :null => false
    t.string   "code_file_name",    :limit => 256
    t.string   "code_content_type", :limit => 64
    t.integer  "code_file_size"
    t.binary   "code_file",         :limit => 16777215
    t.binary   "code_medium_file"
    t.binary   "code_thumb_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submissions", ["deliverable_id", "updated_at"], :name => "index_submissions_on_deliverable_id_and_updated_at"
  add_index "submissions", ["updated_at"], :name => "index_submissions_on_updated_at"
  add_index "submissions", ["user_id", "deliverable_id"], :name => "index_submissions_on_user_id_and_deliverable_id", :unique => true

  create_table "tokens", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.string   "token",      :limit => 64,   :null => false
    t.string   "action",     :limit => 32,   :null => false
    t.string   "argument",   :limit => 1024
    t.datetime "created_at"
  end

  add_index "tokens", ["token"], :name => "index_tokens_on_token", :unique => true
  add_index "tokens", ["user_id", "action"], :name => "index_tokens_on_user_id_and_action"

  create_table "users", :force => true do |t|
    t.string   "name",          :limit => 64,                    :null => false
    t.string   "password_salt", :limit => 16,                    :null => false
    t.string   "password_hash", :limit => 64,                    :null => false
    t.string   "email",         :limit => 64,                    :null => false
    t.boolean  "active",                      :default => false, :null => false
    t.boolean  "admin",                       :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
