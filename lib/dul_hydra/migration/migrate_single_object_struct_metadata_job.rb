module DulHydra::Migration
  class MigrateSingleObjectStructMetadataJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      report = MigrationReport.find_or_create_by(fcrepo3_pid: id)
      unless report.struct_metadata_status == MigrationReport::MIGRATION_SUCCESS
        ActiveSupport::Notifications.instrument('migration_timer',
                                                pid: id,
                                                event: MigrationTimer::STRUCT_METADATA_MIGRATION_EVENT) do
          obj = ActiveFedora::Base.find(id)
          struct_metadata = DulHydra::Migration::StructMetadata.new(obj).migrate
          report.struct_metadata = struct_metadata.to_json
          report.struct_metadata_status = MigrationReport::MIGRATION_SUCCESS
          report.save!
        end
      end
    end

  end
end
