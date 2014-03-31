class AddCsvColSepToExportSet < ActiveRecord::Migration
  def change
    add_column :export_sets, :csv_col_sep, :string
  end
end
