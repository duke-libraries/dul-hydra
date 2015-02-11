# This migration comes from ddr_alerts (originally 20141215160128)
class CreateDdrAlertsMessages < ActiveRecord::Migration
  def up
    unless table_exists?("ddr_alerts_messages")
      create_table "ddr_alerts_messages" do |t|
        t.text    "message"
        t.boolean "active", default: false
        t.timestamps
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end