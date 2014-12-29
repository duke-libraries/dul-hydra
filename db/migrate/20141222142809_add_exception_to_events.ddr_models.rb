# This migration comes from ddr_models (originally 20141218020612)
class AddExceptionToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :exception
    end
  end
end
