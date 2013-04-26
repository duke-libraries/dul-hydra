class LinkBatchToUser < ActiveRecord::Migration
  def up
    add_column :batches, :user_id, :integer
  end

  def down
    drop_column :batches, :user_id
  end
end
