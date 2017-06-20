class RemoveColumnsFromFileDigests < ActiveRecord::Migration
  def change
    remove_column :file_digests, :md5, :string
    remove_column :file_digests, :path, :string
  end
end
