module DulHydra::Migration
  class MigrateSingleObjectStructMetadataJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      report = MigrationReport.find_or_create_by(fcrepo4_id: id)
      unless report.struct_metadata_status == MigrationReport::MIGRATION_SUCCESS
        ActiveSupport::Notifications.instrument('migration_timer',
                                                rept_id: report.id,
                                                event: MigrationTimer::STRUCT_METADATA_MIGRATION_EVENT) do
          struct_metadata = migrate(id)
          make_report(report, struct_metadata)
        end
      end
    end

    private

    def self.migrate(id)
      ActiveSupport::Notifications.instrument(Ddr::Notifications::MIGRATION) do |payload|
        obj = ActiveFedora::Base.find(id)
        struct_metadata = DulHydra::Migration::StructMetadata.new(obj).migrate
        payload[:summary] = 'Object structural metadata migrated'
        payload[:pid] = obj.id
        payload[:software] = "DulHydra #{DulHydra::VERSION}"
        struct_metadata
      end
    end

    def self.make_report(report, struct_metadata)
      report.struct_metadata = struct_metadata.to_json
      report.struct_metadata_status = MigrationReport::MIGRATION_SUCCESS
      report.save!
    end

  end
end
