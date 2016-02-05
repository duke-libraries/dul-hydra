module DulHydra::Migration
  class MigrateSingleObjectJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      report = MigrationReport.find_or_create_by(fcrepo3_pid: id)
      unless report.object_status == MigrationReport::MIGRATION_SUCCESS
        ActiveSupport::Notifications.instrument('migration_timer',
                                                rept_id: report.id,
                                                event: MigrationTimer::OBJECT_MIGRATION_EVENT) do
          object = migrate(id)
          make_report(report, object)
        end
      end
    end

    private

    def self.migrate(id)
      ActiveSupport::Notifications.instrument(Ddr::Notifications::MIGRATION) do |payload|
        object = FedoraMigrate::ObjectMover.new(FedoraMigrate.source.connection.find(id),
                                             nil,
                                             { convert: [ 'mergedMetadata' ] }
        ).migrate
        object['id'] = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => id).first.id
        payload[:pid] = object['id']
        payload[:software] = "DulHydra #{DulHydra::VERSION}"
        object
      end
    end

    def self.make_report(report, object)
      report.model = object['class']
      report.object = object.to_json
      report.object_status = MigrationReport::MIGRATION_SUCCESS
      report.fcrepo4_id = object['id']
      report.save!
    end

  end
end
