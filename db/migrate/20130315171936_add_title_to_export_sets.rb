class AddTitleToExportSets < ActiveRecord::Migration
  def change
    change_table :export_sets do |t|
      t.string :title
    end
  end
end
