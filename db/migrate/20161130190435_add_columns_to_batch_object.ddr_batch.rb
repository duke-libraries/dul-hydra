# This migration comes from ddr_batch (originally 20161115191636)
class AddColumnsToBatchObject < ActiveRecord::Migration
  def change
    change_table :batch_objects do |t|
      t.boolean "handled", default: false
      t.boolean "processed", default: false
      t.boolean "validated", default: false
    end
  end
end
