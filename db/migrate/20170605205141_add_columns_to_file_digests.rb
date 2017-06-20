class AddColumnsToFileDigests < ActiveRecord::Migration
  def change
    change_table :file_digests do |t|
      t.string :path
      t.string :md5
    end
  end
end
