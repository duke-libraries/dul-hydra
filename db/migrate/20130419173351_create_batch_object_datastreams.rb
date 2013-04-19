class CreateBatchObjectDatastreams < ActiveRecord::Migration
  def change
    create_table :batch_object_datastreams do |t|
      t.references :batch_object
      t.string :operation
      t.string :name
      t.text :payload
      t.string :payload_type

      t.timestamps
    end
  end
end
