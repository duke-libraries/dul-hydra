module DulHydra::Migration
  class MigrateSingleObjectJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      report = MigrationReport.find_or_create_by(fcrepo3_pid: id)
      unless report.object_status == MigrationReport::MIGRATION_SUCCESS
        ActiveSupport::Notifications.instrument('migration_timer',
                                                pid: id,
                                                event: MigrationTimer::OBJECT_MIGRATION_EVENT) do
          source_obj = FedoraMigrate.source.connection.find(id)
          object = FedoraMigrate::ObjectMover.new(FedoraMigrate.source.connection.find(id),
                                                  nil,
                                                  { convert: [ 'mergedMetadata' ] }
                                                  ).migrate
          report.model = object['class']
          report.object = object.to_json
          report.object_status = MigrationReport::MIGRATION_SUCCESS
          report.fcrepo4_id = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => id).first.id
          report.save!
        end
      end
    end

  end
end
