class CreatePreservationEvents < ActiveRecord::Migration
  def change
    create_table :preservation_events do |t|
      t.datetime :event_date_time, index: true
      t.text :event_detail
      t.string :event_type, index: true
      t.string :event_id_type
      t.string :event_id_value
      t.string :event_outcome, index: true
      t.text :event_outcome_detail_note
      t.string :linking_object_id_type, index: true
      t.string :linking_object_id_value, index: true
      t.timestamps
    end
  end
end
