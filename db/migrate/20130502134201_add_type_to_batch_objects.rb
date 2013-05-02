class AddTypeToBatchObjects < ActiveRecord::Migration
  def change
    add_column :batch_objects, :type, :string
  end
end
