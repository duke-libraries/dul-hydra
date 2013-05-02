class AddChecksumToBatchObjectDatastreams < ActiveRecord::Migration
  def change
    add_column :batch_object_datastreams, :checksum, :string
    add_column :batch_object_datastreams, :checksum_type, :string
  end
end
