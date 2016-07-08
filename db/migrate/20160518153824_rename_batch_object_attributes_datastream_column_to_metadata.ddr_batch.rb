# This migration comes from ddr_batch (originally 20160510205446)
class RenameBatchObjectAttributesDatastreamColumnToMetadata < ActiveRecord::Migration
  def change
    rename_column :batch_object_attributes, :datastream, :metadata
  end
end
