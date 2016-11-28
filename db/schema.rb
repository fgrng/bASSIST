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

ActiveRecord::Schema.define(version: 20161128142111) do

  create_table "exercises", force: :cascade do |t|
    t.integer  "subject_id"
    t.string   "type",           limit: 255
    t.text     "text"
    t.text     "ideal_solution"
    t.integer  "group_number"
    t.boolean  "is_visible",                 default: false
    t.float    "min_points",                 default: 0.0
    t.float    "max_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exercises_lsa_runs", id: false, force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "lsa_run_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "submission_id"
    t.text     "text",          default: ""
    t.boolean  "passed",        default: false
    t.boolean  "is_visible",    default: false
    t.float    "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lectures", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.datetime "year"
    t.string   "term",              limit: 255
    t.text     "description"
    t.string   "teacher",           limit: 255
    t.integer  "max_group",                     default: 0
    t.datetime "register_start"
    t.datetime "register_stop"
    t.string   "tutor_key",         limit: 255
    t.string   "teacher_key",       limit: 255
    t.boolean  "is_visible",                    default: false
    t.boolean  "closed",                        default: false
    t.boolean  "show_lsa_score",                default: false
    t.string   "statement_name",    limit: 255, default: "Statement"
    t.string   "a_statement_name",  limit: 255, default: "Statement A"
    t.string   "b_statement_name",  limit: 255, default: "Statement B"
    t.string   "c_statement_name",  limit: 255, default: "Statement C"
    t.string   "reflection_name",   limit: 255, default: "Reflektion"
    t.string   "a_reflection_name", limit: 255, default: "Reflektion A"
    t.string   "b_reflection_name", limit: 255, default: "Reflektion B"
    t.string   "c_reflection_name", limit: 255, default: "Reflektion C"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_passage_collections", force: :cascade do |t|
    t.integer  "submission_id"
    t.integer  "source_id"
    t.float    "percentage"
    t.integer  "passage_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_passages", force: :cascade do |t|
    t.integer "lsa_passage_collection_id"
    t.integer "mirror_id"
    t.integer "first"
    t.integer "last"
    t.index ["lsa_passage_collection_id"], name: "index_lsa_passages_on_lsa_passage_collection_id"
  end

  create_table "lsa_plagiarisms", force: :cascade do |t|
    t.integer  "lsa_run_id"
    t.string   "lsa_run_type",                limit: 255
    t.integer  "submission_a_id"
    t.integer  "submission_b_id"
    t.integer  "lsa_passage_collection_a_id"
    t.integer  "lsa_passage_collection_b_id"
    t.float    "cosine"
    t.integer  "watched",                                 default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lsa_passage_collection_a_id"], name: "index_lsa_plagiarisms_on_lsa_passage_collection_a_id"
    t.index ["lsa_passage_collection_b_id"], name: "index_lsa_plagiarisms_on_lsa_passage_collection_b_id"
    t.index ["lsa_run_id", "lsa_run_type"], name: "index_lsa_plagiarisms_on_lsa_run_id_and_lsa_run_type"
    t.index ["submission_a_id"], name: "index_lsa_plagiarisms_on_submission_a_id"
    t.index ["submission_b_id"], name: "index_lsa_plagiarisms_on_submission_b_id"
  end

  create_table "lsa_runs", force: :cascade do |t|
    t.integer  "exercise_id"
    t.integer  "lsa_server_id"
    t.integer  "user_id"
    t.integer  "delayed_job_id"
    t.integer  "lecture_id"
    t.string   "type",               limit: 255
    t.string   "error_message",      limit: 255
    t.text     "ideal_solution"
    t.text     "first_scored_text"
    t.text     "second_scored_text"
    t.float    "first_text_score"
    t.float    "second_text_score"
    t.datetime "schedule_time"
    t.datetime "start_time"
    t.datetime "stop_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_scorings", force: :cascade do |t|
    t.integer  "lsa_run_id"
    t.integer  "submission_id"
    t.string   "lsa_run_type",  limit: 255
    t.float    "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lsa_run_id", "lsa_run_type"], name: "index_lsa_scorings_on_lsa_run_id_and_lsa_run_type"
    t.index ["submission_id"], name: "index_lsa_scorings_on_submission_id"
  end

  create_table "lsa_servers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "json_url",   limit: 255
    t.string   "rmi_url",    limit: 255
    t.integer  "rmi_port"
    t.integer  "json_port"
    t.string   "json_path",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_sortings", force: :cascade do |t|
    t.integer  "lsa_run_id"
    t.integer  "submission_id"
    t.string   "lsa_run_type",  limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lsa_run_id", "lsa_run_type"], name: "index_lsa_sortings_on_lsa_run_id_and_lsa_run_type"
    t.index ["submission_id"], name: "index_lsa_sortings_on_submission_id"
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "lecture_id"
    t.integer  "user_id"
    t.integer  "tutorial_id"
    t.string   "type",         limit: 255
    t.boolean  "validated",                default: false
    t.integer  "group_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lecture_id"], name: "index_roles_on_lecture_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "due_date"
    t.integer  "lecture_id"
    t.datetime "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "exercise_id"
    t.text     "text",                    default: ""
    t.boolean  "is_visible",              default: false
    t.boolean  "external",                default: false
    t.string   "comment",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["exercise_id"], name: "index_submissions_on_exercise_id"
    t.index ["student_id"], name: "index_submissions_on_student_id"
  end

  create_table "tutorials", force: :cascade do |t|
    t.integer  "lecture_id"
    t.integer  "max_students"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "active_lecture_id"
    t.string   "email",                    limit: 255
    t.string   "first_name",               limit: 255
    t.string   "last_name",                limit: 255
    t.string   "password_digest",          limit: 255
    t.boolean  "validated",                            default: false
    t.boolean  "is_admin",                             default: false
    t.boolean  "is_assistant",                         default: false
    t.string   "remember_token",           limit: 255
    t.string   "password_reset_token",     limit: 255
    t.datetime "password_reset_sent_at"
    t.string   "email_validation_token",   limit: 255
    t.datetime "email_validation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
