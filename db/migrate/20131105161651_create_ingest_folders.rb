class CreateIngestFolders < ActiveRecord::Migration
  def change
    create_table :ingest_folders do |t|
      t.references :user
      t.string :base_path
      t.string :sub_path
      t.string :admin_policy_pid
      t.string :collection_pid
      t.string :model
      t.string :file_creator
      t.string :checksum_file
      t.string :checksum_type
      t.boolean :add_parents
      t.integer :parent_id_length

      t.timestamps
    end
  end
end
