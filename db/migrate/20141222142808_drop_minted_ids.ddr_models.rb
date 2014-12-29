# This migration comes from ddr_models (originally 20141216040225)
class DropMintedIds < ActiveRecord::Migration
  def up
    drop_table :minted_ids
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
