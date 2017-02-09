class CreateFileDigests < ActiveRecord::Migration
  def change
    create_table :file_digests do |t|
      t.string :repo_id
      t.string :file_id
      t.string :sha1
      t.timestamps
    end

    add_index :file_digests, [:repo_id, :file_id], unique: true
  end
end
