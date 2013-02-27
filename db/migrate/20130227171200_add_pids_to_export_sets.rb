class AddPidsToExportSets < ActiveRecord::Migration
  def change
    add_column :export_sets, :pids, :text
  end
end