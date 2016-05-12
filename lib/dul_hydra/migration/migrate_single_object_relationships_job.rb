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
          rels = migrate(id)
          make_report(report, rels)
        end
      end
    end

    private

    def self.migrate(id)
      ActiveSupport::Notifications.instrument(Ddr::Notifications::MIGRATION) do |payload|
        rels = FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.source.connection.find(id)).migrate
        payload[:summary] = 'Object relationships migrated'
        payload[:pid] = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => id).first.id
        payload[:software] = "DulHydra #{DulHydra::VERSION}"
        rels
      end
    end

    def self.make_report(report, rels)
      report.relationships = rels.to_json
      report.relationship_status = MigrationReport::MIGRATION_SUCCESS
      report.save!
    end

  end
end
