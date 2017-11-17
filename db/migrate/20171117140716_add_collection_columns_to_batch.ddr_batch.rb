# This migration comes from ddr_batch (originally 20171116183514)
class AddCollectionColumnsToBatch < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.string "collection_id", null: true
      t.string "collection_title", null: true
    end
  end
end
