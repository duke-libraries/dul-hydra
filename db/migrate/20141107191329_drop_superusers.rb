class DropSuperusers < ActiveRecord::Migration
  def change
    drop_table :superusers do
      t.integer "user_id", null: false
    end
  end
end
