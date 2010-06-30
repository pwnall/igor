# This file is auto-generated from the current state of the database. Instead 
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your 
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100503235401) do

  create_table "announcements", :force => true do |t|
    t.string   "headline",         :limit => 128,                     :null => false
    t.string   "contents",         :limit => 8192,                    :null => false
    t.integer  "author_id",                                           :null => false
    t.boolean  "open_to_visitors",                 :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "deadline",                                            :null => false
    t.string   "name",               :limit => 64,                    :null => false
    t.integer  "team_partition_id"
    t.integer  "feedback_survey_id"
    t.boolean  "accepts_feedback",                 :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "number",          :limit => 16,                    :null => false
    t.string   "title",           :limit => 256,                   :null => false
    t.string   "ga_account",      :limit => 32,                    :null => false
    t.boolean  "has_recitations",                :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["number"], :name => "index_courses_on_number", :unique => true

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
    t.integer  "metric_id",                                                :null => false
    t.string   "subject_type", :limit => 64,                               :null => false
    t.integer  "subject_id",                                               :null => false
    t.integer  "grader_id",                                                :null => false
    t.decimal  "score",                      :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grades", ["subject_type", "subject_id", "metric_id"], :name => "grades_by_subject_and_metric_id", :unique => true

  create_table "notice_statuses", :force => true do |t|
    t.integer "announcement_id",                    :null => false
    t.integer "user_id",                            :null => false
    t.boolean "seen",            :default => false, :null => false
  end

  add_index "notice_statuses", ["user_id", "announcement_id"], :name => "index_notice_statuses_on_user_id_and_announcement_id", :unique => true

  create_table "prerequisite_answers", :force => true do |t|
    t.integer  "registration_id", :null => false
    t.integer  "prerequisite_id", :null => false
    t.boolean  "took_course",     :null => false
    t.text     "waiver_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prerequisite_answers", ["registration_id", "prerequisite_id"], :name => "prerequisites_for_a_registration", :unique => true

  create_table "prerequisites", :force => true do |t|
    t.string   "course_number",   :limit => 64,  :null => false
    t.string   "waiver_question", :limit => 256, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_photos", :force => true do |t|
    t.integer  "profile_id",                           :null => false
    t.string   "pic_file_name",    :limit => 256,      :null => false
    t.string   "pic_content_type", :limit => 64,       :null => false
    t.integer  "pic_file_size",                        :null => false
    t.binary   "pic_file",         :limit => 16777215, :null => false
    t.binary   "pic_profile_file", :limit => 16777215, :null => false
    t.binary   "pic_thumb_file",   :limit => 16777215, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_photos", ["profile_id"], :name => "index_profile_photos_on_profile_id", :unique => true

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",                                                 :null => false
    t.string   "real_name",             :limit => 128,                    :null => false
    t.string   "nickname",              :limit => 64,                     :null => false
    t.string   "university",            :limit => 64,                     :null => false
    t.string   "department",            :limit => 64,                     :null => false
    t.string   "year",                  :limit => 4,                      :null => false
    t.string   "athena_username",       :limit => 32,                     :null => false
    t.string   "about_me",              :limit => 4096, :default => "",   :null => false
    t.boolean  "allows_publishing",                     :default => true, :null => false
    t.string   "phone_number",          :limit => 64
    t.string   "aim_name",              :limit => 64
    t.string   "jabber_name",           :limit => 64
    t.integer  "recitation_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id", :unique => true

  create_table "recitation_conflicts", :force => true do |t|
    t.integer "registration_id", :null => false
    t.integer "timeslot",        :null => false
    t.string  "class_name",      :null => false
  end

  add_index "recitation_conflicts", ["registration_id", "timeslot"], :name => "index_recitation_conflicts_on_registration_id_and_timeslot", :unique => true

  create_table "recitation_sections", :force => true do |t|
    t.integer  "serial",                   :null => false
    t.integer  "leader_id",                :null => false
    t.string   "time",       :limit => 64, :null => false
    t.string   "location",   :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recitation_sections", ["serial"], :name => "index_recitation_sections_on_serial", :unique => true

  create_table "registrations", :force => true do |t|
    t.integer  "user_id",                                           :null => false
    t.integer  "course_id",                                         :null => false
    t.boolean  "dropped",                        :default => false, :null => false
    t.boolean  "for_credit",                     :default => true,  :null => false
    t.text     "motivation", :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrations", ["course_id", "user_id"], :name => "index_registrations_on_course_id_and_user_id", :unique => true
  add_index "registrations", ["user_id", "course_id"], :name => "index_registrations_on_user_id_and_course_id", :unique => true

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

  create_table "submissions", :force => true do |t|
    t.integer  "deliverable_id",                        :null => false
    t.integer  "user_id",                               :null => false
    t.string   "code_file_name",    :limit => 256
    t.string   "code_content_type", :limit => 64
    t.integer  "code_file_size"
    t.binary   "code_file",         :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submissions", ["deliverable_id", "updated_at"], :name => "index_submissions_on_deliverable_id_and_updated_at"
  add_index "submissions", ["updated_at"], :name => "index_submissions_on_updated_at"
  add_index "submissions", ["user_id", "deliverable_id"], :name => "index_submissions_on_user_id_and_deliverable_id", :unique => true

  create_table "survey_answers", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "assignment_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_answers", ["assignment_id"], :name => "index_survey_answers_on_assignment_id"
  add_index "survey_answers", ["user_id", "assignment_id"], :name => "index_survey_answers_on_user_id_and_assignment_id", :unique => true

  create_table "survey_question_answers", :force => true do |t|
    t.integer  "survey_answer_id",                 :null => false
    t.integer  "question_id",                      :null => false
    t.integer  "target_user_id"
    t.float    "number",                           :null => false
    t.string   "comment",          :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_question_answers", ["survey_answer_id", "question_id", "target_user_id"], :name => "survey_question_answers_by_answer_question_user", :unique => true

  create_table "survey_question_memberships", :force => true do |t|
    t.integer  "survey_question_id", :null => false
    t.integer  "survey_id",          :null => false
    t.datetime "created_at"
  end

  add_index "survey_question_memberships", ["survey_id", "survey_question_id"], :name => "survey_questions_to_surveys", :unique => true
  add_index "survey_question_memberships", ["survey_question_id", "survey_id"], :name => "surveys_to_survey_questions", :unique => true

  create_table "survey_questions", :force => true do |t|
    t.string   "human_string",    :limit => 1024,                      :null => false
    t.boolean  "targets_user",                    :default => false,   :null => false
    t.boolean  "allows_comments",                 :default => false,   :null => false
    t.boolean  "scaled",                          :default => false,   :null => false
    t.integer  "scale_min",                       :default => 1,       :null => false
    t.integer  "scale_max",                       :default => 5,       :null => false
    t.string   "scale_min_label", :limit => 64,   :default => "Small", :null => false
    t.string   "scale_max_label", :limit => 64,   :default => "Large", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.string   "name",       :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_memberships", :force => true do |t|
    t.integer  "team_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
  end

  add_index "team_memberships", ["team_id", "user_id"], :name => "index_team_memberships_on_team_id_and_user_id", :unique => true
  add_index "team_memberships", ["user_id", "team_id"], :name => "index_team_memberships_on_user_id_and_team_id", :unique => true

  create_table "team_partitions", :force => true do |t|
    t.string   "name",       :limit => 64,                    :null => false
    t.boolean  "automated",                :default => true,  :null => false
    t.boolean  "editable",                 :default => true,  :null => false
    t.boolean  "published",                :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.integer  "partition_id",               :null => false
    t.string   "name",         :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["partition_id", "name"], :name => "index_teams_on_partition_id_and_name", :unique => true

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
