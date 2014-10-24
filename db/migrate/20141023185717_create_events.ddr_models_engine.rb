# This migration comes from ddr_models_engine (originally 20141021233359)
class CreateEvents < ActiveRecord::Migration
  def up
    unless table_exists?("events")
      create_table "events" do |t|
        t.datetime "event_date_time"
        t.integer  "user_id"
        t.string   "type"
        t.string   "pid"
        t.string   "software"
        t.text     "comment"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "summary"
        t.string   "outcome"
        t.text     "detail"
      end

      add_index "events", ["event_date_time"], name: "index_events_on_event_date_time"
      add_index "events", ["outcome"], name: "index_events_on_outcome"
      add_index "events", ["pid"], name: "index_events_on_pid"
      add_index "events", ["type"], name: "index_events_on_type"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
