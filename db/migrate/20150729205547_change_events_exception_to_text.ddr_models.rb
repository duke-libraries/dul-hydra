# This migration comes from ddr_models (originally 20150710211530)
class ChangeEventsExceptionToText < ActiveRecord::Migration
  def up
    change_column :events, :exception, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
