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

  create_table "analyses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "submission_id", limit: 4,        null: false
    t.integer  "status_code",   limit: 4,        null: false
    t.integer  "score",         limit: 4
    t.text     "log",           limit: 16777215, null: false
    t.text     "private_log",   limit: 16777215, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["submission_id"], name: "index_analyses_on_submission_id", unique: true, using: :btree
  end

  create_table "analyzers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "deliverable_id", limit: 4,                     null: false
    t.string   "type",           limit: 32,                    null: false
    t.boolean  "auto_grading",                 default: false, null: false
    t.text     "exec_limits",    limit: 65535
    t.integer  "db_file_id",     limit: 4
    t.string   "message_name",   limit: 64
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.index ["deliverable_id"], name: "index_analyzers_on_deliverable_id", unique: true, using: :btree
  end

  create_table "announcements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "author_id",        limit: 4,                    null: false
    t.string   "headline",         limit: 128,                  null: false
    t.string   "contents",         limit: 8192,                 null: false
    t.boolean  "open_to_visitors",              default: false, null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "assignment_metrics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "assignment_id", limit: 4,  null: false
    t.string   "name",          limit: 64, null: false
    t.integer  "max_score",     limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["assignment_id", "name"], name: "index_assignment_metrics_on_assignment_id_and_name", unique: true, using: :btree
  end

  create_table "assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "course_id",          limit: 4,                                           null: false
    t.integer  "author_id",          limit: 4,                                           null: false
    t.integer  "team_partition_id",  limit: 4
    t.integer  "feedback_survey_id", limit: 4
    t.datetime "deadline",                                                               null: false
    t.decimal  "weight",                        precision: 16, scale: 8, default: 1.0,   null: false
    t.string   "name",               limit: 64,                                          null: false
    t.boolean  "deliverables_ready",                                     default: false, null: false
    t.boolean  "metrics_ready",                                          default: false, null: false
    t.boolean  "accepts_feedback",                                       default: false, null: false
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.index ["course_id", "deadline", "name"], name: "index_assignments_on_course_id_and_deadline_and_name", unique: true, using: :btree
    t.index ["course_id", "name"], name: "index_assignments_on_course_id_and_name", unique: true, using: :btree
  end

  create_table "courses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "number",                 limit: 16,  null: false
    t.string   "title",                  limit: 256, null: false
    t.string   "ga_account",             limit: 32,  null: false
    t.string   "email",                  limit: 64,  null: false
    t.boolean  "email_on_role_requests",             null: false
    t.boolean  "has_recitations",                    null: false
    t.boolean  "has_surveys",                        null: false
    t.boolean  "has_teams",                          null: false
    t.integer  "section_size",           limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["number"], name: "index_courses_on_number", unique: true, using: :btree
  end

  create_table "credentials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",    limit: 4,    null: false
    t.string   "type",       limit: 32,   null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",              null: false
    t.binary   "key",        limit: 2048
    t.index ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
    t.index ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
    t.index ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree
  end

  create_table "db_file_blobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "db_file_id",    limit: 4,          null: false
    t.string  "style",         limit: 16
    t.binary  "file_contents", limit: 4294967295
    t.index ["db_file_id", "style"], name: "index_db_file_blobs_on_db_file_id_and_style", unique: true, using: :btree
  end

  create_table "db_files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at",                 null: false
    t.string   "f_file_name",    limit: 255
    t.string   "f_content_type", limit: 255
    t.integer  "f_file_size",    limit: 4
    t.datetime "f_updated_at"
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "deliverables", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "assignment_id", limit: 4,    null: false
    t.string   "file_ext",      limit: 16,   null: false
    t.string   "name",          limit: 80,   null: false
    t.string   "description",   limit: 2048, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["assignment_id", "name"], name: "index_deliverables_on_assignment_id_and_name", unique: true, using: :btree
  end

  create_table "grade_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "grade_id",   limit: 4,    null: false
    t.integer  "grader_id",  limit: 4,    null: false
    t.string   "comment",    limit: 4096, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["grade_id"], name: "index_grade_comments_on_grade_id", unique: true, using: :btree
  end

  create_table "grades", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "metric_id",    limit: 4,                          null: false
    t.integer  "grader_id",    limit: 4,                          null: false
    t.string   "subject_type", limit: 64
    t.integer  "subject_id",   limit: 4,                          null: false
    t.decimal  "score",                   precision: 8, scale: 2, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["metric_id"], name: "index_grades_on_metric_id", using: :btree
    t.index ["subject_id", "subject_type", "metric_id"], name: "grades_by_subject_and_metric", unique: true, using: :btree
  end

  create_table "photo_blobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "profile_photo_id", limit: 4,        null: false
    t.string  "style",            limit: 16
    t.binary  "file_contents",    limit: 16777215, null: false
    t.index ["profile_photo_id", "style"], name: "index_photo_blobs_on_profile_photo_id_and_style", unique: true, using: :btree
  end

  create_table "prerequisite_answers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "registration_id", limit: 4,     null: false
    t.integer  "prerequisite_id", limit: 4,     null: false
    t.boolean  "took_course",                   null: false
    t.text     "waiver_answer",   limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["registration_id", "prerequisite_id"], name: "prerequisites_for_a_registration", unique: true, using: :btree
  end

  create_table "prerequisites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "course_id",           limit: 4,   null: false
    t.string   "prerequisite_number", limit: 64,  null: false
    t.string   "waiver_question",     limit: 256, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["course_id", "prerequisite_number"], name: "index_prerequisites_on_course_id_and_prerequisite_number", unique: true, using: :btree
  end

  create_table "profile_photos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "profile_id",       limit: 4,   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "pic_file_name",    limit: 255
    t.string   "pic_content_type", limit: 255
    t.integer  "pic_file_size",    limit: 4
    t.datetime "pic_updated_at"
    t.index ["profile_id"], name: "index_profile_photos_on_profile_id", unique: true, using: :btree
  end

  create_table "profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",         limit: 4,   null: false
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

  create_table "recitation_assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "recitation_partition_id", limit: 4, null: false
    t.integer "user_id",                 limit: 4, null: false
    t.integer "recitation_section_id",   limit: 4, null: false
    t.index ["recitation_partition_id", "recitation_section_id"], name: "recitation_assignments_to_sections", using: :btree
    t.index ["recitation_partition_id", "user_id"], name: "recitation_assignments_to_partitions", unique: true, using: :btree
  end

  create_table "recitation_conflicts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "registration_id", limit: 4,   null: false
    t.integer "timeslot",        limit: 4,   null: false
    t.string  "class_name",      limit: 255, null: false
    t.index ["registration_id", "timeslot"], name: "index_recitation_conflicts_on_registration_id_and_timeslot", unique: true, using: :btree
  end

  create_table "recitation_partitions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "course_id",     limit: 4, null: false
    t.integer  "section_size",  limit: 4, null: false
    t.integer  "section_count", limit: 4, null: false
    t.datetime "created_at"
    t.index ["course_id"], name: "index_recitation_partitions_on_course_id", using: :btree
  end

  create_table "recitation_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "course_id",  limit: 4,  null: false
    t.integer  "leader_id",  limit: 4
    t.integer  "serial",     limit: 4,  null: false
    t.string   "time",       limit: 64, null: false
    t.string   "location",   limit: 64, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["course_id", "serial"], name: "index_recitation_sections_on_course_id_and_serial", unique: true, using: :btree
  end

  create_table "registrations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",               limit: 4,                 null: false
    t.integer  "course_id",             limit: 4,                 null: false
    t.boolean  "dropped",                         default: false, null: false
    t.boolean  "for_credit",                                      null: false
    t.boolean  "allows_publishing",                               null: false
    t.integer  "recitation_section_id", limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["course_id", "user_id"], name: "index_registrations_on_course_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "course_id"], name: "index_registrations_on_user_id_and_course_id", unique: true, using: :btree
  end

  create_table "role_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.string   "name",       limit: 8, null: false
    t.integer  "course_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["course_id", "name", "user_id"], name: "index_role_requests_on_course_id_and_name_and_user_id", unique: true, using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.string   "name",       limit: 8, null: false
    t.integer  "course_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["course_id", "name", "user_id"], name: "index_roles_on_course_id_and_name_and_user_id", unique: true, using: :btree
  end

  create_table "submissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "deliverable_id", limit: 4,   null: false
    t.integer  "db_file_id",     limit: 4,   null: false
    t.string   "subject_type",   limit: 255, null: false
    t.integer  "subject_id",     limit: 4,   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["deliverable_id", "updated_at"], name: "index_submissions_on_deliverable_id_and_updated_at", using: :btree
    t.index ["subject_id", "subject_type", "deliverable_id"], name: "index_submissions_on_subject_id_and_type_and_deliverable_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_submissions_on_updated_at", using: :btree
  end

  create_table "survey_answers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",       limit: 4, null: false
    t.integer  "assignment_id", limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["assignment_id"], name: "index_survey_answers_on_assignment_id", using: :btree
    t.index ["user_id", "assignment_id"], name: "index_survey_answers_on_user_id_and_assignment_id", unique: true, using: :btree
  end

  create_table "survey_question_answers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "survey_answer_id", limit: 4,    null: false
    t.integer  "question_id",      limit: 4,    null: false
    t.integer  "target_user_id",   limit: 4
    t.float    "number",           limit: 24,   null: false
    t.string   "comment",          limit: 1024
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["survey_answer_id", "question_id", "target_user_id"], name: "survey_question_answers_by_answer_question_user", unique: true, using: :btree
  end

  create_table "survey_question_memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "survey_question_id", limit: 4, null: false
    t.integer  "survey_id",          limit: 4, null: false
    t.datetime "created_at"
    t.index ["survey_id", "survey_question_id"], name: "survey_questions_to_surveys", unique: true, using: :btree
    t.index ["survey_question_id", "survey_id"], name: "surveys_to_survey_questions", unique: true, using: :btree
  end

  create_table "survey_questions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "scale_min",       limit: 4,    default: 1,       null: false
    t.integer  "scale_max",       limit: 4,    default: 5,       null: false
    t.boolean  "scaled",                       default: false,   null: false
    t.boolean  "targets_user",                 default: false,   null: false
    t.boolean  "allows_comments",              default: false,   null: false
    t.string   "human_string",    limit: 1024,                   null: false
    t.string   "scale_min_label", limit: 64,   default: "Small", null: false
    t.string   "scale_max_label", limit: 64,   default: "Large", null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "surveys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",       limit: 128, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "team_invitations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "inviter_id", limit: 4
    t.integer  "invitee_id", limit: 4
    t.integer  "team_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "team_memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "team_id",    limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at"
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "team_id"], name: "index_team_memberships_on_user_id_and_team_id", unique: true, using: :btree
  end

  create_table "team_partitions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",       limit: 64,                 null: false
    t.integer  "min_size",   limit: 4,                  null: false
    t.integer  "max_size",   limit: 4,                  null: false
    t.boolean  "automated",             default: true,  null: false
    t.boolean  "editable",              default: true,  null: false
    t.boolean  "published",             default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["name"], name: "index_team_partitions_on_name", unique: true, using: :btree
  end

  create_table "teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "partition_id", limit: 4,  null: false
    t.string   "name",         limit: 64, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["partition_id", "name"], name: "index_teams_on_partition_id_and_name", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "exuid",      limit: 32, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree
  end

end
