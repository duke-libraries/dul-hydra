# This migration comes from ddr_batch (originally 20160816164010)
class CreateBatchObjectRoles < ActiveRecord::Migration
  def change
    unless table_exists?(:batch_object_roles)
      create_table :batch_object_roles do |t|
        t.integer  "batch_object_id"
        t.string   "operation"
        t.string   "agent"
        t.string   "role_type"
        t.string   "role_scope"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
    end
  end
end
