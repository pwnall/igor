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

ActiveRecord::Schema.define(version: 20110704070001) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.integer  "submission_id", null: false
    t.integer  "status_code",   null: false
    t.text     "log",           null: false
    t.text     "private_log",   null: false
    t.text     "scores"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["submission_id"], name: "index_analyses_on_submission_id", unique: true, using: :btree
  end

  create_table "analyzers", force: :cascade do |t|
    t.integer  "deliverable_id",            null: false
    t.string   "type",           limit: 32, null: false
    t.boolean  "auto_grading",              null: false
    t.text     "exec_limits"
    t.integer  "db_file_id"
    t.string   "message_name",   limit: 64
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["db_file_id"], name: "index_analyzers_on_db_file_id", unique: true, using: :btree
  end

  create_table "announcements", force: :cascade do |t|
    t.integer  "author_id",                                     null: false
    t.integer  "course_id",                                     null: false
    t.string   "headline",         limit: 128,                  null: false
    t.string   "contents",         limit: 8192,                 null: false
    t.boolean  "open_to_visitors",              default: false, null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "assignment_files", force: :cascade do |t|
    t.string   "description",   limit: 64, null: false
    t.integer  "assignment_id",            null: false
    t.integer  "db_file_id",               null: false
    t.datetime "released_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["assignment_id"], name: "index_assignment_files_on_assignment_id", using: :btree
    t.index ["db_file_id"], name: "index_assignment_files_on_db_file_id", unique: true, using: :btree
  end

  create_table "assignment_metrics", force: :cascade do |t|
    t.integer  "assignment_id",                                     null: false
    t.string   "name",          limit: 64,                          null: false
    t.integer  "max_score",                                         null: false
    t.decimal  "weight",                   precision: 16, scale: 8, null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.index ["assignment_id", "name"], name: "index_assignment_metrics_on_assignment_id_and_name", unique: true, using: :btree
  end

  create_table "assignments", force: :cascade do |t|
    t.integer  "course_id",                                             null: false
    t.integer  "author_id",                                             null: false
    t.string   "name",              limit: 64,                          null: false
    t.boolean  "scheduled",                                             null: false
    t.datetime "released_at"
    t.boolean  "grades_released",                                       null: false
    t.decimal  "weight",                       precision: 16, scale: 8, null: false
    t.integer  "team_partition_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.index ["course_id", "name"], name: "index_assignments_on_course_id_and_name", unique: true, using: :btree
    t.index ["course_id", "released_at", "name"], name: "index_assignments_on_course_id_and_released_at_and_name", unique: true, using: :btree
  end

  create_table "collaborations", force: :cascade do |t|
    t.integer "submission_id",   null: false
    t.integer "collaborator_id", null: false
    t.index ["submission_id", "collaborator_id"], name: "index_collaborations_on_submission_id_and_collaborator_id", unique: true, using: :btree
  end

  create_table "courses", force: :cascade do |t|
    t.string   "number",                 limit: 16,  null: false
    t.string   "title",                  limit: 256, null: false
    t.string   "ga_account",             limit: 32,  null: false
    t.string   "email",                  limit: 64,  null: false
    t.boolean  "email_on_role_requests",             null: false
    t.boolean  "has_recitations",                    null: false
    t.boolean  "has_surveys",                        null: false
    t.boolean  "has_teams",                          null: false
    t.integer  "section_size"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["number"], name: "index_courses_on_number", unique: true, using: :btree
  end

  create_table "credentials", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "type",       limit: 32,  null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",             null: false
    t.binary   "key"
    t.index ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
    t.index ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
    t.index ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree
  end

  create_table "db_file_blobs", force: :cascade do |t|
    t.integer "db_file_id",               null: false
    t.string  "style",         limit: 16
    t.binary  "file_contents"
    t.index ["db_file_id", "style"], name: "index_db_file_blobs_on_db_file_id_and_style", unique: true, using: :btree
  end

  create_table "db_files", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.string   "f_file_name"
    t.string   "f_content_type"
    t.integer  "f_file_size"
    t.datetime "f_updated_at"
  end

  create_table "deadline_extensions", force: :cascade do |t|
    t.string   "subject_type", null: false
    t.integer  "subject_id",   null: false
    t.integer  "user_id",      null: false
    t.integer  "grantor_id"
    t.datetime "due_at",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["subject_id", "subject_type", "user_id"], name: "index_deadline_extensions_on_subject_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_deadline_extensions_on_user_id", using: :btree
  end

  create_table "deadlines", force: :cascade do |t|
    t.string   "subject_type", null: false
    t.integer  "subject_id",   null: false
    t.datetime "due_at",       null: false
    t.integer  "course_id",    null: false
    t.index ["course_id"], name: "index_deadlines_on_course_id", using: :btree
    t.index ["subject_type", "subject_id"], name: "index_deadlines_on_subject_type_and_subject_id", unique: true, using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "deliverables", force: :cascade do |t|
    t.integer  "assignment_id",              null: false
    t.string   "file_ext",      limit: 16,   null: false
    t.string   "name",          limit: 80,   null: false
    t.string   "description",   limit: 2048, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["assignment_id", "name"], name: "index_deliverables_on_assignment_id_and_name", unique: true, using: :btree
  end

  create_table "email_resolvers", force: :cascade do |t|
    t.string  "domain",           limit: 128, null: false
    t.text    "ldap_server",                  null: false
    t.text    "ldap_auth_dn"
    t.text    "ldap_password",                null: false
    t.text    "ldap_search_base",             null: false
    t.text    "name_ldap_key",                null: false
    t.text    "dept_ldap_key",                null: false
    t.text    "year_ldap_key",                null: false
    t.text    "user_ldap_key",                null: false
    t.boolean "use_ldaps",                    null: false
    t.index ["domain"], name: "index_email_resolvers_on_domain", unique: true, using: :btree
  end

  create_table "grade_comments", force: :cascade do |t|
    t.integer  "course_id",               null: false
    t.integer  "metric_id",               null: false
    t.integer  "grader_id",               null: false
    t.string   "subject_type", limit: 16
    t.integer  "subject_id",              null: false
    t.text     "text",                    null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["subject_id", "subject_type", "course_id"], name: "index_grade_comments_on_subject_and_course_id", using: :btree
    t.index ["subject_id", "subject_type", "metric_id"], name: "index_grade_comments_on_subject_and_metric_id", unique: true, using: :btree
  end

  create_table "grades", force: :cascade do |t|
    t.integer  "course_id",                                       null: false
    t.integer  "metric_id",                                       null: false
    t.integer  "grader_id",                                       null: false
    t.string   "subject_type", limit: 64
    t.integer  "subject_id",                                      null: false
    t.decimal  "score",                   precision: 8, scale: 2, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["metric_id"], name: "index_grades_on_metric_id", using: :btree
    t.index ["subject_id", "subject_type", "course_id"], name: "index_grades_on_subject_id_and_subject_type_and_course_id", using: :btree
    t.index ["subject_id", "subject_type", "metric_id"], name: "index_grades_on_subject_id_and_subject_type_and_metric_id", unique: true, using: :btree
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photo_blobs", force: :cascade do |t|
    t.integer "profile_photo_id",            null: false
    t.string  "style",            limit: 16
    t.binary  "file_contents",               null: false
    t.index ["profile_photo_id", "style"], name: "index_photo_blobs_on_profile_photo_id_and_style", unique: true, using: :btree
  end

  create_table "prerequisite_answers", force: :cascade do |t|
    t.integer  "registration_id", null: false
    t.integer  "prerequisite_id", null: false
    t.boolean  "took_course",     null: false
    t.text     "waiver_answer"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["registration_id", "prerequisite_id"], name: "prerequisites_for_a_registration", unique: true, using: :btree
  end

  create_table "prerequisites", force: :cascade do |t|
    t.integer  "course_id",                       null: false
    t.string   "prerequisite_number", limit: 64,  null: false
    t.string   "waiver_question",     limit: 256, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["course_id", "prerequisite_number"], name: "index_prerequisites_on_course_id_and_prerequisite_number", unique: true, using: :btree
  end

  create_table "profile_photos", force: :cascade do |t|
    t.integer  "profile_id",       null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "pic_file_name"
    t.string   "pic_content_type"
    t.integer  "pic_file_size"
    t.datetime "pic_updated_at"
    t.index ["profile_id"], name: "index_profile_photos_on_profile_id", unique: true, using: :btree
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.string   "name",            limit: 128, null: false
    t.string   "nickname",        limit: 64,  null: false
    t.string   "university",      limit: 64,  null: false
    t.string   "department",      limit: 64,  null: false
    t.string   "year",            limit: 4,   null: false
    t.string   "athena_username", limit: 32,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true, using: :btree
  end

  create_table "recitation_assignments", force: :cascade do |t|
    t.integer "recitation_partition_id", null: false
    t.integer "user_id",                 null: false
    t.integer "recitation_section_id",   null: false
    t.index ["recitation_partition_id", "recitation_section_id"], name: "recitation_assignments_to_sections", using: :btree
    t.index ["recitation_partition_id", "user_id"], name: "recitation_assignments_to_partitions", unique: true, using: :btree
  end

  create_table "recitation_conflicts", force: :cascade do |t|
    t.integer "registration_id", null: false
    t.integer "time_slot_id",    null: false
    t.string  "class_name",      null: false
    t.index ["registration_id", "time_slot_id"], name: "index_recitation_conflicts_on_registration_id_and_time_slot_id", unique: true, using: :btree
  end

  create_table "recitation_partitions", force: :cascade do |t|
    t.integer  "course_id",     null: false
    t.integer  "section_size",  null: false
    t.integer  "section_count", null: false
    t.datetime "created_at"
    t.index ["course_id"], name: "index_recitation_partitions_on_course_id", using: :btree
  end

  create_table "recitation_sections", force: :cascade do |t|
    t.integer  "course_id",             null: false
    t.integer  "leader_id"
    t.integer  "serial",                null: false
    t.string   "location",   limit: 64, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["course_id", "serial"], name: "index_recitation_sections_on_course_id_and_serial", unique: true, using: :btree
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "user_id",                               null: false
    t.integer  "course_id",                             null: false
    t.boolean  "dropped",               default: false, null: false
    t.boolean  "for_credit",                            null: false
    t.boolean  "allows_publishing",                     null: false
    t.integer  "recitation_section_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["course_id", "user_id"], name: "index_registrations_on_course_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "course_id"], name: "index_registrations_on_user_id_and_course_id", unique: true, using: :btree
  end

  create_table "role_requests", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.string   "name",       limit: 8, null: false
    t.integer  "course_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["course_id", "name", "user_id"], name: "index_role_requests_on_course_id_and_name_and_user_id", unique: true, using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.string   "name",       limit: 8, null: false
    t.integer  "course_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["course_id", "name", "user_id"], name: "index_roles_on_course_id_and_name_and_user_id", unique: true, using: :btree
    t.index ["user_id", "course_id"], name: "index_roles_on_user_id_and_course_id", using: :btree
  end

  create_table "smtp_servers", force: :cascade do |t|
    t.string  "host",          limit: 128, null: false
    t.integer "port",                      null: false
    t.string  "domain",        limit: 128, null: false
    t.string  "user_name",     limit: 128, null: false
    t.string  "password",      limit: 128, null: false
    t.string  "from",          limit: 128, null: false
    t.string  "auth_kind"
    t.boolean "auto_starttls",             null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "deliverable_id",            null: false
    t.integer  "db_file_id",                null: false
    t.string   "subject_type",              null: false
    t.integer  "subject_id",                null: false
    t.integer  "uploader_id",               null: false
    t.string   "upload_ip",      limit: 48, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["db_file_id"], name: "index_submissions_on_db_file_id", unique: true, using: :btree
    t.index ["deliverable_id", "updated_at"], name: "index_submissions_on_deliverable_id_and_updated_at", using: :btree
    t.index ["subject_id", "subject_type", "deliverable_id"], name: "index_submissions_on_subject_id_and_type_and_deliverable_id", using: :btree
    t.index ["updated_at"], name: "index_submissions_on_updated_at", using: :btree
  end

  create_table "survey_answers", force: :cascade do |t|
    t.integer  "question_id",                                      null: false
    t.integer  "response_id",                                      null: false
    t.decimal  "number",                   precision: 7, scale: 2
    t.string   "comment",     limit: 1024
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["response_id", "question_id"], name: "index_survey_answers_on_response_id_and_question_id", unique: true, using: :btree
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "survey_id",                    null: false
    t.string   "prompt",          limit: 1024, null: false
    t.boolean  "allows_comments",              null: false
    t.string   "type",            limit: 32,   null: false
    t.text     "features",                     null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "survey_responses", force: :cascade do |t|
    t.integer  "course_id",  null: false
    t.integer  "user_id",    null: false
    t.integer  "survey_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_survey_responses_on_course_id", using: :btree
    t.index ["user_id", "survey_id"], name: "index_survey_responses_on_user_id_and_survey_id", unique: true, using: :btree
  end

  create_table "surveys", force: :cascade do |t|
    t.string   "name",       limit: 128, null: false
    t.boolean  "released",               null: false
    t.integer  "course_id",              null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["course_id", "name"], name: "index_surveys_on_course_id_and_name", unique: true, using: :btree
  end

  create_table "team_memberships", force: :cascade do |t|
    t.integer  "team_id",    null: false
    t.integer  "user_id",    null: false
    t.integer  "course_id",  null: false
    t.datetime "created_at"
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "course_id"], name: "index_team_memberships_on_user_id_and_course_id", using: :btree
    t.index ["user_id", "team_id"], name: "index_team_memberships_on_user_id_and_team_id", unique: true, using: :btree
  end

  create_table "team_partitions", force: :cascade do |t|
    t.integer  "course_id",                             null: false
    t.string   "name",       limit: 64,                 null: false
    t.integer  "min_size",                              null: false
    t.integer  "max_size",                              null: false
    t.boolean  "automated",             default: true,  null: false
    t.boolean  "editable",              default: true,  null: false
    t.boolean  "released",              default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["course_id", "name"], name: "index_team_partitions_on_course_id_and_name", unique: true, using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "partition_id",            null: false
    t.string   "name",         limit: 64, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["partition_id", "name"], name: "index_teams_on_partition_id_and_name", unique: true, using: :btree
  end

  create_table "time_slot_allotments", force: :cascade do |t|
    t.integer "time_slot_id",          null: false
    t.integer "recitation_section_id", null: false
    t.index ["recitation_section_id", "time_slot_id"], name: "index_time_slot_allotments_on_recitation_section_and_time_slot", unique: true, using: :btree
    t.index ["recitation_section_id"], name: "index_time_slot_allotments_on_recitation_section_id", using: :btree
    t.index ["time_slot_id"], name: "index_time_slot_allotments_on_time_slot_id", using: :btree
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "course_id",           null: false
    t.integer "day",       limit: 2, null: false
    t.integer "starts_at",           null: false
    t.integer "ends_at",             null: false
    t.index ["course_id", "day", "starts_at", "ends_at"], name: "index_time_slots_on_course_id_and_day_and_starts_at_and_ends_at", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "exuid",      limit: 32, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree
  end

  add_foreign_key "analyzers", "db_files"
  add_foreign_key "assignment_files", "assignments"
  add_foreign_key "assignment_files", "db_files"
  add_foreign_key "collaborations", "submissions"
  add_foreign_key "deadline_extensions", "users"
  add_foreign_key "deadline_extensions", "users", column: "grantor_id", on_delete: :nullify
  add_foreign_key "time_slot_allotments", "recitation_sections"
  add_foreign_key "time_slot_allotments", "time_slots"
end
