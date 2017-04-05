class AddMd5ToFileDigests < ActiveRecord::Migration
  def change
    change_table :file_digests do |t|
      t.string :md5
    end
  end
end
