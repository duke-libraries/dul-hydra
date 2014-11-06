# This migration comes from ddr_models (originally 20141104181418)
class CreateUsers < ActiveRecord::Migration
  def up
    unless table_exists?("users")
      create_table "users" do |t|
        t.string   "email",                  default: "", null: false
        t.string   "encrypted_password",     default: "", null: false
        t.string   "reset_password_token"
        t.datetime "reset_password_sent_at"
        t.datetime "remember_created_at"
        t.integer  "sign_in_count",          default: 0
        t.datetime "current_sign_in_at"
        t.datetime "last_sign_in_at"
        t.string   "current_sign_in_ip"
        t.string   "last_sign_in_ip"
        t.datetime "created_at",                          null: false
        t.datetime "updated_at",                          null: false
        t.string   "username",               default: "", null: false
        t.string   "first_name"
        t.string   "middle_name"
        t.string   "nickname"
        t.string   "last_name"
        t.string   "display_name"
      end

      add_index "users", ["email"], name: "index_users_on_email"
      add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      add_index "users", ["username"], name: "index_users_on_username", unique: true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
