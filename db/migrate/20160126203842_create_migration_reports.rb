class CreateMigrationReports < ActiveRecord::Migration
  def change
    create_table :migration_reports do |t|
      t.string :fcrepo3_pid
      t.string :fcrepo4_id
      t.string :model
      t.string :object_status, default: DulHydra::Migration::MigrationReport::MIGRATION_NEEDED
      t.string :relationship_status, default: DulHydra::Migration::MigrationReport::MIGRATION_NEEDED
      t.string :struct_metadata_status
      t.text :object, limit: 65535
      t.text :relationships, limit: 65535
      t.text :struct_metadata, limit: 65535

      t.timestamps
    end

    add_index :migration_reports, :fcrepo3_pid, unique: true
    add_index :migration_reports, :fcrepo4_id, unique: true
    add_index :migration_reports, :model
    add_index :migration_reports, :object_status
    add_index :migration_reports, :relationship_status
    add_index :migration_reports, :struct_metadata_status

    create_table :migration_timers do |t|
      t.belongs_to :migration_report, index: true
      t.string :event
      t.float :duration

      t.timestamps
    end

  end
end
