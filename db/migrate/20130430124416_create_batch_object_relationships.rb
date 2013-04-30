class CreateBatchObjectRelationships < ActiveRecord::Migration
  def change
    create_table :batch_object_relationships do |t|
      t.references :batch_object
      t.string :name
      t.string :operation
      t.string :object
      t.string :object_type

      t.timestamps
    end
  end
end
