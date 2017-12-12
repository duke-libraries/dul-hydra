class RemoveFileCreatorFromIngestFolder < ActiveRecord::Migration
  def up
    remove_column :ingest_folders, :file_creator
  end

  def down
    add_column :ingest_folders, :file_creator, :string
  end
end
