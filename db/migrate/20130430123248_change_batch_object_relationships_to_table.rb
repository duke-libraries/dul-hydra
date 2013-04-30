class ChangeBatchObjectRelationshipsToTable < ActiveRecord::Migration
  def change
    remove_column :batch_objects, :admin_policy
    remove_column :batch_objects, :parent
    remove_column :batch_objects, :target_for
  end
end
