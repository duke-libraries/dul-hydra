class AddNameFieldsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :first_name
      t.string :middle_name
      t.string :nickname
      t.string :last_name
      t.string :display_name
    end
  end
end
