# This migration comes from ddr_models (originally 20141103192146)
class CreateWorkflowState < ActiveRecord::Migration
  def change
    create_table "workflow_states" do |t|
      t.string   "pid"
      t.string   "workflow_state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "workflow_states", ["pid"], name: "index_workflow_states_on_pid", unique: true
    add_index "workflow_states", ["workflow_state"], name: "index_workflow_states_on_workflow_state"
  end
end
