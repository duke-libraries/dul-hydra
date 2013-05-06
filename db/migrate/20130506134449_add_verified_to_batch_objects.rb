class AddVerifiedToBatchObjects < ActiveRecord::Migration
  def change
    add_column :batch_objects, :verified, :boolean, :default => false
  end
end
