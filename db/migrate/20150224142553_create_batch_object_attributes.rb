class CreateBatchObjectAttributes < ActiveRecord::Migration
  def change
    create_table :batch_object_attributes do |t|
      t.references :batch_object
      t.string :datastream
      t.string :name
      t.string :operation
      t.string :value
      t.string :value_type

      t.timestamps
    end
  end
end
