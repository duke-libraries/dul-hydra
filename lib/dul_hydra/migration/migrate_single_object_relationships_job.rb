module DulHydra::Migration
  class MigrateSingleObjectRelationshipsJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      report = MigrationReport.find_or_create_by(fcrepo3_pid: id)
      unless report.relationship_status == MigrationReport::MIGRATION_SUCCESS
        ActiveSupport::Notifications.instrument('migration_timer',
                                                rept_id: report.id,
                                                event: MigrationTimer::RELATIONSHIP_MIGRATION_EVENT) do
          rels = FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.source.connection.find(id)).migrate
          report.relationships = rels.to_json
          report.relationship_status = MigrationReport::MIGRATION_SUCCESS
          report.save!
        end
      end
    end

  end
end
