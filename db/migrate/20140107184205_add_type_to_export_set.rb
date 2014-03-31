class AddTypeToExportSet < ActiveRecord::Migration
  def change
    add_column :export_sets, :export_type, :string
  end
end
