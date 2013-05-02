class RemoveOperationFromBatchObjects < ActiveRecord::Migration
  def up
    remove_column :batch_objects, :operation
  end

  def down
    add_column :batch_objects, :operation, :string
  end
end
