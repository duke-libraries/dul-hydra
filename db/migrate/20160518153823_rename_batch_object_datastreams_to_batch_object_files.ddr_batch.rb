# This migration comes from ddr_batch (originally 20160510202953)
class RenameBatchObjectDatastreamsToBatchObjectFiles < ActiveRecord::Migration
  def change
    rename_table :batch_object_datastreams, :batch_object_files
  end
end
