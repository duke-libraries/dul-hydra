class IncreaseBatchDetailsSize < ActiveRecord::Migration
  def up
    change_column :batches, :details, :text, :limit => 16777215
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
