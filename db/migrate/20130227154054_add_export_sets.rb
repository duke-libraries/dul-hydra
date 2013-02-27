class AddExportSets < ActiveRecord::Migration
  def up
    create_table :export_sets do |t|
      t.references :user
      t.timestamps
      t.attachment :archive
    end
  end

  def down
    drop_table :export_sets
  end
end
