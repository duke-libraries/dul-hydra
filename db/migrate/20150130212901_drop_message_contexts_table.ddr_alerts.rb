# This migration comes from ddr_alerts (originally 20150130204030)
class DropMessageContextsTable < ActiveRecord::Migration

  def up
    if table_exists?("ddr_alerts_message_contexts")
      drop_table "ddr_alerts_message_contexts"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
