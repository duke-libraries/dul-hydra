class RemoveTotalFromBatches < ActiveRecord::Migration
  def up
    remove_column :batches, :total
  end

  def down
    add_column :batches, :total, :integer
  end
end
