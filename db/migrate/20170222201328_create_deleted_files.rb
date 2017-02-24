class CreateDeletedFiles < ActiveRecord::Migration
  def change
    create_table :deleted_files do |t|
      t.string :repo_id
      t.string :file_id
      t.string :version_id
      t.string :source, index: true
      t.string :path
      t.datetime :last_modified, index: true
    end

    add_index :deleted_files, [:repo_id, :file_id, :version_id]
  end
end
