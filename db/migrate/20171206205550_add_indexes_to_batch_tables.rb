class AddIndexesToBatchTables < ActiveRecord::Migration
  def change
    add_index :batch_object_attributes, :batch_object_id
    add_index :batch_object_datastreams, :batch_object_id
    add_index :batch_object_messages, :batch_object_id
    add_index :batch_object_relationships, :batch_object_id
    add_index :batch_object_relationships, :name
    add_index :batch_object_relationships, :object
    add_index :batch_object_roles, :batch_object_id
    add_index :batch_objects, :batch_id
    add_index :batch_objects, :updated_at
  end
end
