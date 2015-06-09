class ChangeValueFromStringToText < ActiveRecord::Migration

  def up
    change_column :batch_object_attributes, :value, :text, limit: 65535
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
