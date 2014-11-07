class DropPreservationEvents < ActiveRecord::Migration
  def up
    drop_table :preservation_events
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
