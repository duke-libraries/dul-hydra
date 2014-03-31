class AddMetadataFiles < ActiveRecord::Migration
  def up
    create_table :metadata_files do |t|
      t.references :user
      t.string :profile
      t.string :collection_pid
      t.timestamps
      t.attachment :metadata
    end
  end

  def down
    drop_table :metadata_files
  end
end
