# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20121020145804) do
=======
ActiveRecord::Schema.define(:version => 20131114025608) do
>>>>>>> ming/master

  create_table "analyses", force: true do |t|
    t.integer  "submission_id",                  null: false
    t.integer  "status_code",                    null: false
    t.integer  "score"
    t.text     "log",           limit: 16777215, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "analyses", ["submission_id"], name: "index_analyses_on_submission_id", unique: true, using: :btree

  create_table "analyzers", force: true do |t|
    t.integer  "deliverable_id",                            null: false
    t.string   "type",           limit: 32,                 null: false
    t.boolean  "auto_grading",              default: false, null: false
    t.text     "exec_limits"
    t.integer  "db_file_id"
    t.string   "message_name",   limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "analyzers", ["deliverable_id"], name: "index_analyzers_on_deliverable_id", unique: true, using: :btree

  create_table "announcements", force: true do |t|
    t.integer  "author_id",                                     null: false
    t.string   "headline",         limit: 128,                  null: false
    t.string   "contents",         limit: 8192,                 null: false
    t.boolean  "open_to_visitors",              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_metrics", force: true do |t|
    t.integer  "assignment_id",            null: false
    t.string   "name",          limit: 64, null: false
    t.integer  "max_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignment_metrics", ["assignment_id", "name"], name: "index_assignment_metrics_on_assignment_id_and_name", unique: true, using: :btree

  create_table "assignments", force: true do |t|
    t.integer  "course_id",                                                              null: false
    t.integer  "author_id",                                                              null: false
    t.integer  "team_partition_id"
    t.integer  "feedback_survey_id"
<<<<<<< HEAD
    t.datetime "deadline",                                                               null: false
    t.decimal  "weight",                        precision: 16, scale: 8, default: 1.0,   null: false
    t.string   "name",               limit: 64,                                          null: false
    t.boolean  "deliverables_ready",                                     default: false, null: false
    t.boolean  "metrics_ready",                                          default: false, null: false
    t.boolean  "accepts_feedback",                                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["course_id", "deadline", "name"], name: "index_assignments_on_course_id_and_deadline_and_name", unique: true, using: :btree
  add_index "assignments", ["course_id", "name"], name: "index_assignments_on_course_id_and_name", unique: true, using: :btree

  create_table "courses", force: true do |t|
    t.string   "number",          limit: 16,                 null: false
    t.string   "title",           limit: 256,                null: false
    t.string   "ga_account",      limit: 32,                 null: false
    t.string   "email",           limit: 64,                 null: false
    t.boolean  "has_recitations",             default: true, null: false
    t.boolean  "has_surveys",                 default: true, null: false
    t.boolean  "has_teams",                   default: true, null: false
    t.integer  "section_size",                default: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["number"], name: "index_courses_on_number", unique: true, using: :btree

  create_table "credentials", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "type",       limit: 32,   null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",              null: false
    t.binary   "key",        limit: 2048
  end

  add_index "credentials", ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
  add_index "credentials", ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
  add_index "credentials", ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree

  create_table "db_file_blobs", force: true do |t|
    t.integer "db_file_id",                       null: false
    t.string  "style",         limit: 16
    t.binary  "file_contents", limit: 2147483647
  end

  add_index "db_file_blobs", ["db_file_id", "style"], name: "index_db_file_blobs_on_db_file_id_and_style", unique: true, using: :btree

  create_table "db_files", force: true do |t|
    t.datetime "created_at",     null: false
    t.string   "f_file_name"
    t.string   "f_content_type"
    t.integer  "f_file_size"
    t.datetime "f_updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
=======
    t.datetime "deadline",                                                                           :null => false
    t.decimal  "weight",                           :precision => 16, :scale => 8, :default => 1.0,   :null => false
    t.string   "name",               :limit => 64,                                                   :null => false
    t.boolean  "deliverables_ready",                                              :default => false, :null => false
    t.boolean  "metrics_ready",                                                   :default => false, :null => false
    t.boolean  "accepts_feedback",                                                :default => false, :null => false
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
  end

  add_index "assignments", ["course_id", "deadline", "name"], :name => "index_assignments_on_course_id_and_deadline_and_name", :unique => true
  add_index "assignments", ["course_id", "name"], :name => "index_assignments_on_course_id_and_name", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "grade_id",                   :null => false
    t.integer  "grader_id",                  :null => false
    t.string   "comment",    :limit => 1024
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "comments", ["grade_id"], :name => "index_comments_on_grade_id", :unique => true

  create_table "courses", :force => true do |t|
    t.string   "number",          :limit => 16,                    :null => false
    t.string   "title",           :limit => 256,                   :null => false
    t.string   "ga_account",      :limit => 32,                    :null => false
    t.string   "email",           :limit => 64,                    :null => false
    t.boolean  "has_recitations",                :default => true, :null => false
    t.boolean  "has_surveys",                    :default => true, :null => false
    t.boolean  "has_teams",                      :default => true, :null => false
    t.integer  "section_size",                   :default => 20
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "courses", ["number"], :name => "index_courses_on_number", :unique => true

  create_table "credentials", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.string   "type",       :limit => 32,  :null => false
    t.string   "name",       :limit => 128
    t.datetime "updated_at",                :null => false
    t.binary   "key"
  end

  add_index "credentials", ["type", "name"], :name => "index_credentials_on_type_and_name", :unique => true
  add_index "credentials", ["type", "updated_at"], :name => "index_credentials_on_type_and_updated_at"
  add_index "credentials", ["user_id", "type"], :name => "index_credentials_on_user_id_and_type"

  create_table "db_files", :force => true do |t|
    t.text    "f_file_name",                          :null => false
    t.string  "f_content_type",                       :null => false
    t.integer "f_file_size",                          :null => false
    t.binary  "f_file",         :limit => 2147483647, :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
>>>>>>> ming/master
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliverables", force: true do |t|
    t.integer  "assignment_id",              null: false
    t.string   "file_ext",      limit: 16,   null: false
    t.string   "name",          limit: 80,   null: false
    t.string   "description",   limit: 2048, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deliverables", ["assignment_id", "name"], name: "index_deliverables_on_assignment_id_and_name", unique: true, using: :btree

  create_table "grades", force: true do |t|
    t.integer  "metric_id",                                       null: false
    t.integer  "grader_id",                                       null: false
    t.integer  "subject_id",                                      null: false
    t.string   "subject_type", limit: 64
    t.decimal  "score",                   precision: 8, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grades", ["metric_id"], name: "index_grades_on_metric_id", using: :btree
  add_index "grades", ["subject_id", "subject_type", "metric_id"], name: "grades_by_subject_and_metric", unique: true, using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_blobs", force: true do |t|
    t.integer "profile_photo_id",                  null: false
    t.string  "style",            limit: 16
    t.binary  "file_contents",    limit: 16777215, null: false
  end

  add_index "photo_blobs", ["profile_photo_id", "style"], name: "index_photo_blobs_on_profile_photo_id_and_style", unique: true, using: :btree

  create_table "prerequisite_answers", force: true do |t|
    t.integer  "registration_id", null: false
    t.integer  "prerequisite_id", null: false
    t.boolean  "took_course",     null: false
    t.text     "waiver_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prerequisite_answers", ["registration_id", "prerequisite_id"], name: "prerequisites_for_a_registration", unique: true, using: :btree

  create_table "prerequisites", force: true do |t|
    t.integer  "course_id",                       null: false
    t.string   "prerequisite_number", limit: 64,  null: false
    t.string   "waiver_question",     limit: 256, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prerequisites", ["course_id", "prerequisite_number"], name: "index_prerequisites_on_course_id_and_prerequisite_number", unique: true, using: :btree

  create_table "profile_photos", force: true do |t|
    t.integer  "profile_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pic_file_name"
    t.string   "pic_content_type"
    t.integer  "pic_file_size"
    t.datetime "pic_updated_at"
  end

  add_index "profile_photos", ["profile_id"], name: "index_profile_photos_on_profile_id", unique: true, using: :btree

  create_table "profiles", force: true do |t|
    t.integer  "user_id",                                   null: false
    t.string   "name",            limit: 128,               null: false
    t.string   "nickname",        limit: 64,                null: false
    t.string   "university",      limit: 64,                null: false
    t.string   "department",      limit: 64,                null: false
    t.string   "year",            limit: 4,                 null: false
    t.string   "athena_username", limit: 32,                null: false
    t.string   "about_me",        limit: 4096, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", unique: true, using: :btree

  create_table "recitation_assignments", force: true do |t|
    t.integer "recitation_partition_id", null: false
    t.integer "user_id",                 null: false
    t.integer "recitation_section_id",   null: false
  end

  add_index "recitation_assignments", ["recitation_partition_id", "recitation_section_id"], name: "recitation_assignments_to_sections", using: :btree
  add_index "recitation_assignments", ["recitation_partition_id", "user_id"], name: "recitation_assignments_to_partitions", unique: true, using: :btree

  create_table "recitation_conflicts", force: true do |t|
    t.integer "registration_id", null: false
    t.integer "timeslot",        null: false
    t.string  "class_name",      null: false
  end

  add_index "recitation_conflicts", ["registration_id", "timeslot"], name: "index_recitation_conflicts_on_registration_id_and_timeslot", unique: true, using: :btree

  create_table "recitation_partitions", force: true do |t|
    t.integer  "course_id",     null: false
    t.integer  "section_size",  null: false
    t.integer  "section_count", null: false
    t.datetime "created_at"
  end

  add_index "recitation_partitions", ["course_id"], name: "index_recitation_partitions_on_course_id", using: :btree

  create_table "recitation_sections", force: true do |t|
    t.integer  "course_id",             null: false
    t.integer  "leader_id",             null: false
    t.integer  "serial",                null: false
    t.string   "time",       limit: 64, null: false
    t.string   "location",   limit: 64, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recitation_sections", ["course_id", "serial"], name: "index_recitation_sections_on_course_id_and_serial", unique: true, using: :btree

  create_table "registrations", force: true do |t|
    t.integer  "user_id",                               null: false
    t.integer  "course_id",                             null: false
    t.boolean  "dropped",               default: false, null: false
    t.boolean  "teacher",               default: false, null: false
    t.boolean  "for_credit",            default: true,  null: false
    t.boolean  "allows_publishing",     default: true,  null: false
    t.integer  "recitation_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrations", ["course_id", "user_id"], name: "index_registrations_on_course_id_and_user_id", unique: true, using: :btree
  add_index "registrations", ["user_id", "course_id"], name: "index_registrations_on_user_id_and_course_id", unique: true, using: :btree

  create_table "submissions", force: true do |t|
    t.integer  "deliverable_id", null: false
    t.integer  "db_file_id",     null: false
    t.integer  "subject_id",     null: false
    t.string   "subject_type",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submissions", ["deliverable_id", "updated_at"], name: "index_submissions_on_deliverable_id_and_updated_at", using: :btree
  add_index "submissions", ["subject_id", "subject_type", "deliverable_id"], name: "index_submissions_on_subject_id_and_type_and_deliverable_id", unique: true, using: :btree
  add_index "submissions", ["updated_at"], name: "index_submissions_on_updated_at", using: :btree

  create_table "survey_answers", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "assignment_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_answers", ["assignment_id"], name: "index_survey_answers_on_assignment_id", using: :btree
  add_index "survey_answers", ["user_id", "assignment_id"], name: "index_survey_answers_on_user_id_and_assignment_id", unique: true, using: :btree

  create_table "survey_question_answers", force: true do |t|
    t.integer  "survey_answer_id",              null: false
    t.integer  "question_id",                   null: false
    t.integer  "target_user_id"
    t.float    "number",                        null: false
    t.string   "comment",          limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_question_answers", ["survey_answer_id", "question_id", "target_user_id"], name: "survey_question_answers_by_answer_question_user", unique: true, using: :btree

  create_table "survey_question_memberships", force: true do |t|
    t.integer  "survey_question_id", null: false
    t.integer  "survey_id",          null: false
    t.datetime "created_at"
  end

  add_index "survey_question_memberships", ["survey_id", "survey_question_id"], name: "survey_questions_to_surveys", unique: true, using: :btree
  add_index "survey_question_memberships", ["survey_question_id", "survey_id"], name: "surveys_to_survey_questions", unique: true, using: :btree

  create_table "survey_questions", force: true do |t|
    t.integer  "scale_min",                    default: 1,       null: false
    t.integer  "scale_max",                    default: 5,       null: false
    t.boolean  "scaled",                       default: false,   null: false
    t.boolean  "targets_user",                 default: false,   null: false
    t.boolean  "allows_comments",              default: false,   null: false
    t.string   "human_string",    limit: 1024,                   null: false
    t.string   "scale_min_label", limit: 64,   default: "Small", null: false
    t.string   "scale_max_label", limit: 64,   default: "Large", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", force: true do |t|
    t.string   "name",       limit: 128, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_memberships", force: true do |t|
    t.integer  "team_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
  end

  add_index "team_memberships", ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true, using: :btree
  add_index "team_memberships", ["user_id", "team_id"], name: "index_team_memberships_on_user_id_and_team_id", unique: true, using: :btree

  create_table "team_partitions", force: true do |t|
    t.string   "name",       limit: 64,                 null: false
    t.integer  "min_size",                              null: false
    t.integer  "max_size",                              null: false
    t.boolean  "automated",             default: true,  null: false
    t.boolean  "editable",              default: true,  null: false
    t.boolean  "published",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_partitions", ["name"], name: "index_team_partitions_on_name", unique: true, using: :btree

  create_table "teams", force: true do |t|
    t.integer  "partition_id",            null: false
    t.string   "name",         limit: 64, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["partition_id", "name"], name: "index_teams_on_partition_id_and_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "exuid",      limit: 32,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                 default: false, null: false
  end

  add_index "users", ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree

end
