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

ActiveRecord::Schema.define(version: 20150920114230) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "exercises", force: true do |t|
    t.integer  "subject_id"
    t.string   "type"
    t.text     "text"
    t.text     "ideal_solution"
    t.integer  "group_number"
    t.boolean  "is_visible",     default: false
    t.float    "min_points",     default: 0.0
    t.float    "max_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exercises_lsa_runs", id: false, force: true do |t|
    t.integer "exercise_id"
    t.integer "lsa_run_id"
  end

  create_table "feedbacks", force: true do |t|
    t.integer  "submission_id"
    t.text     "text",          default: ""
    t.boolean  "passed",        default: false
    t.boolean  "is_visible",    default: false
    t.float    "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lectures", force: true do |t|
    t.string   "name"
    t.datetime "year"
    t.string   "term"
    t.text     "description"
    t.string   "teacher"
    t.integer  "max_group",         default: 0
    t.datetime "register_start"
    t.datetime "register_stop"
    t.string   "tutor_key"
    t.string   "teacher_key"
    t.boolean  "is_visible",        default: false
    t.boolean  "closed",            default: false
    t.boolean  "show_lsa_score",    default: false
    t.string   "statement_name",    default: "Statement"
    t.string   "a_statement_name",  default: "Statement A"
    t.string   "b_statement_name",  default: "Statement B"
    t.string   "c_statement_name",  default: "Statement C"
    t.string   "reflection_name",   default: "Reflektion"
    t.string   "a_reflection_name", default: "Reflektion A"
    t.string   "b_reflection_name", default: "Reflektion B"
    t.string   "c_reflection_name", default: "Reflektion C"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_passage_collections", force: true do |t|
    t.integer  "submission_id"
    t.integer  "source_id"
    t.float    "percentage"
    t.integer  "passage_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_passages", force: true do |t|
    t.integer "lsa_passage_collection_id"
    t.integer "mirror_id"
    t.integer "first"
    t.integer "last"
  end

  add_index "lsa_passages", ["lsa_passage_collection_id"], name: "index_lsa_passages_on_lsa_passage_collection_id"

  create_table "lsa_plagiarisms", force: true do |t|
    t.integer  "lsa_run_id"
    t.string   "lsa_run_type"
    t.integer  "submission_a_id"
    t.integer  "submission_b_id"
    t.integer  "lsa_passage_collection_a_id"
    t.integer  "lsa_passage_collection_b_id"
    t.float    "cosine"
    t.integer  "watched",                     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lsa_plagiarisms", ["lsa_passage_collection_a_id"], name: "index_lsa_plagiarisms_on_lsa_passage_collection_a_id"
  add_index "lsa_plagiarisms", ["lsa_passage_collection_b_id"], name: "index_lsa_plagiarisms_on_lsa_passage_collection_b_id"
  add_index "lsa_plagiarisms", ["lsa_run_id", "lsa_run_type"], name: "index_lsa_plagiarisms_on_lsa_run_id_and_lsa_run_type"
  add_index "lsa_plagiarisms", ["submission_a_id"], name: "index_lsa_plagiarisms_on_submission_a_id"
  add_index "lsa_plagiarisms", ["submission_b_id"], name: "index_lsa_plagiarisms_on_submission_b_id"

  create_table "lsa_runs", force: true do |t|
    t.integer  "exercise_id"
    t.integer  "lsa_server_id"
    t.integer  "user_id"
    t.integer  "delayed_job_id"
    t.integer  "lecture_id"
    t.string   "type"
    t.string   "error_message"
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

  create_table "lsa_scorings", force: true do |t|
    t.integer  "lsa_run_id"
    t.integer  "submission_id"
    t.string   "lsa_run_type"
    t.float    "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lsa_scorings", ["lsa_run_id", "lsa_run_type"], name: "index_lsa_scorings_on_lsa_run_id_and_lsa_run_type"
  add_index "lsa_scorings", ["submission_id"], name: "index_lsa_scorings_on_submission_id"

  create_table "lsa_servers", force: true do |t|
    t.string   "name"
    t.string   "json_url"
    t.string   "rmi_url"
    t.integer  "rmi_port"
    t.integer  "json_port"
    t.string   "json_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lsa_sortings", force: true do |t|
    t.integer  "lsa_run_id"
    t.integer  "submission_id"
    t.string   "lsa_run_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lsa_sortings", ["lsa_run_id", "lsa_run_type"], name: "index_lsa_sortings_on_lsa_run_id_and_lsa_run_type"
  add_index "lsa_sortings", ["submission_id"], name: "index_lsa_sortings_on_submission_id"

  create_table "roles", force: true do |t|
    t.integer  "lecture_id"
    t.integer  "user_id"
    t.integer  "tutorial_id"
    t.string   "type"
    t.boolean  "validated",    default: false
    t.integer  "group_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["lecture_id"], name: "index_roles_on_lecture_id"

  create_table "subjects", force: true do |t|
    t.string   "name"
    t.datetime "due_date"
    t.integer  "lecture_id"
    t.datetime "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", force: true do |t|
    t.integer  "student_id"
    t.integer  "exercise_id"
    t.text     "text",        default: ""
    t.boolean  "is_visible",  default: false
    t.boolean  "external",    default: false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submissions", ["exercise_id"], name: "index_submissions_on_exercise_id"
  add_index "submissions", ["student_id"], name: "index_submissions_on_student_id"

  create_table "tutorials", force: true do |t|
    t.integer  "lecture_id"
    t.integer  "max_students"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "active_lecture_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_digest"
    t.boolean  "validated",                default: false
    t.boolean  "is_admin",                 default: false
    t.boolean  "is_assistant",             default: false
    t.string   "remember_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "email_validation_token"
    t.datetime "email_validation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
