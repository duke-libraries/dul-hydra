class RemoveDetailsFromBatch < ActiveRecord::Migration
  def up
    remove_column :batches, :details
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
    add_column :batches, :details, :text, :limit => 16777215
  end
end
