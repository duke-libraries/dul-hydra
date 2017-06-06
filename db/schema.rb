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

ActiveRecord::Schema.define(version: 20170606140633) do

  create_table "batch_object_attributes", force: :cascade do |t|
    t.integer  "batch_object_id"
    t.string   "datastream",      limit: 255
    t.string   "name",            limit: 255
    t.string   "operation",       limit: 255
    t.text     "value",           limit: 65535
    t.string   "value_type",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_object_datastreams", force: :cascade do |t|
    t.integer  "batch_object_id"
    t.string   "operation",       limit: 255
    t.string   "name",            limit: 255
    t.text     "payload"
    t.string   "payload_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "checksum",        limit: 255
    t.string   "checksum_type",   limit: 255
  end

  create_table "batch_object_messages", force: :cascade do |t|
    t.integer  "batch_object_id"
    t.integer  "level",                         default: 0
    t.text     "message",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_object_relationships", force: :cascade do |t|
    t.integer  "batch_object_id"
    t.string   "name",            limit: 255
    t.string   "operation",       limit: 255
    t.string   "object",          limit: 255
    t.string   "object_type",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_object_roles", force: :cascade do |t|
    t.integer  "batch_object_id"
    t.string   "operation",       limit: 255
    t.string   "agent",           limit: 255
    t.string   "role_type",       limit: 255
    t.string   "role_scope",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_objects", force: :cascade do |t|
    t.integer  "batch_id"
    t.string   "identifier", limit: 255
    t.string   "model",      limit: 255
    t.string   "label",      limit: 255
    t.string   "pid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       limit: 255
    t.boolean  "verified",               default: false
    t.boolean  "handled",                default: false
    t.boolean  "processed",              default: false
    t.boolean  "validated",              default: false
  end

  add_index "batch_objects", ["verified"], name: "index_batch_objects_on_verified"

  create_table "batches", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "description",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "status",                limit: 255
    t.datetime "start"
    t.datetime "stop"
    t.string   "outcome",               limit: 255
    t.string   "version",               limit: 255
    t.string   "logfile_file_name",     limit: 255
    t.string   "logfile_content_type",  limit: 255
    t.integer  "logfile_file_size"
    t.datetime "logfile_updated_at"
    t.datetime "processing_step_start"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "document_id",   limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",     limit: 255
    t.string   "document_type", limit: 255
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "ddr_alerts_messages", force: :cascade do |t|
    t.text     "message"
    t.boolean  "active",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deleted_files", force: :cascade do |t|
    t.string   "repo_id"
    t.string   "file_id"
    t.string   "version_id"
    t.string   "source"
    t.string   "path"
    t.datetime "last_modified"
  end

  add_index "deleted_files", ["last_modified"], name: "index_deleted_files_on_last_modified"
  add_index "deleted_files", ["repo_id", "file_id", "version_id"], name: "index_deleted_files_on_repo_id_and_file_id_and_version_id"
  add_index "deleted_files", ["source"], name: "index_deleted_files_on_source"

  create_table "events", force: :cascade do |t|
    t.datetime "event_date_time"
    t.integer  "user_id"
    t.string   "type",            limit: 255
    t.string   "pid",             limit: 255
    t.string   "software",        limit: 255
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "summary",         limit: 255
    t.string   "outcome",         limit: 255
    t.text     "detail"
    t.text     "exception",       limit: 65535
    t.string   "user_key",        limit: 255
    t.string   "permanent_id",    limit: 255
  end

  add_index "events", ["event_date_time"], name: "index_events_on_event_date_time"
  add_index "events", ["outcome"], name: "index_events_on_outcome"
  add_index "events", ["permanent_id"], name: "index_events_on_permanent_id"
  add_index "events", ["pid"], name: "index_events_on_pid"
  add_index "events", ["type"], name: "index_events_on_type"

  create_table "file_digests", force: :cascade do |t|
    t.string   "repo_id"
    t.string   "file_id"
    t.string   "sha1"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_digests", ["repo_id", "file_id"], name: "index_file_digests_on_repo_id_and_file_id"

  create_table "ingest_folders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "base_path",        limit: 255
    t.string   "sub_path",         limit: 255
    t.string   "admin_policy_pid", limit: 255
    t.string   "collection_pid",   limit: 255
    t.string   "model",            limit: 255
    t.string   "file_creator",     limit: 255
    t.string   "checksum_file",    limit: 255
    t.string   "checksum_type",    limit: 255
    t.boolean  "add_parents"
    t.integer  "parent_id_length"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metadata_files", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "profile",               limit: 255
    t.string   "collection_pid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "metadata_file_name",    limit: 255
    t.string   "metadata_content_type", limit: 255
    t.integer  "metadata_file_size"
    t.datetime "metadata_updated_at"
  end

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",    limit: 255
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 255, default: "", null: false
    t.string   "first_name",             limit: 255
    t.string   "middle_name",            limit: 255
    t.string   "nickname",               limit: 255
    t.string   "last_name",              limit: 255
    t.string   "display_name",           limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
