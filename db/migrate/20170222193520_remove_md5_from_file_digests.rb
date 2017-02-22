require_relative '20170216210541_add_md5_to_file_digests'

class RemoveMd5FromFileDigests < ActiveRecord::Migration
  def change
    revert AddMd5ToFileDigests
  end
end
