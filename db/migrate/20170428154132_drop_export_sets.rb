class DropExportSets < ActiveRecord::Migration
  def up
    drop_table :export_sets
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
