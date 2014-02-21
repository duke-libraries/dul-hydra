class CreateEventLog < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.datetime :event_date_time
      t.string :agent_type
      t.references :user
      t.string :software_agent_value
      t.string :action
      t.string :model
      t.string :object_identifier
      t.string :application_version
      t.text :comment
      
      t.timestamps
    end
  end
end
