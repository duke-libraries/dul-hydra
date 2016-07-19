class IncreaseMigrationReportsColumnSize < ActiveRecord::Migration
  def up
    change_column :migration_reports, :struct_metadata, :text, limit: 16777215
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
