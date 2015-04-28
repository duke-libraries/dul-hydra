# This migration comes from ddr_models (originally 20150110023410)
class DropWorkflowStates < ActiveRecord::Migration
  def up
    if table_exists?("workflow_states")
      drop_table "workflow_states"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
