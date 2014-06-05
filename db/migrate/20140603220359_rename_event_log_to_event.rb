class RenameEventLogToEvent < ActiveRecord::Migration
  def up
    rename_table :event_logs, :events
    change_table :events do |t|
      t.rename :object_identifier, :pid
      t.rename :action, :type
      t.rename :application_version, :software
      t.string :summary, :outcome
      t.text :detail
      t.remove :model, :agent_type, :software_agent_value
      t.index :event_date_time
      t.index :pid
      t.index :type
      t.index :outcome
    end
  end

  def down
    change_table :events do |t|
      t.remove_index :event_date_time
      t.remove_index :pid
      t.remove_index :type
      t.rename :pid, :object_identifier
      t.rename :type, :action
      t.rename :software, :application_version
      t.remove :summary, :outcome, :detail
      t.string :model, :agent_type, :software_agent_value
    end
    rename_table :events, :event_logs
  end
end
