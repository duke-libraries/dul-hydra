# This migration comes from ddr_models (originally 20150130134416)
class AddUserKeyToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :user_key
    end
  end
end
