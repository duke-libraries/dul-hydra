class CreateBatchObjects < ActiveRecord::Migration
  def change
    create_table :batch_objects do |t|
      t.references :batch
      t.string :operation
      t.string :identifier
      t.string :model
      t.string :admin_policy
      t.string :label
      t.string :parent
      t.string :target_for
      t.string :pid

      t.timestamps
    end
  end
end
