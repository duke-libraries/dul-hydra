module DulHydra::Migration
  class MigrateListObjectStructMetadata

    attr_reader :pid_list

    def initialize(pid_list_file_path)
      @pid_list = []
      File.open(pid_list_file_path).each_line { |line| pid_list.push line.chomp }
    end

    def migrate
      pid_list.each do |pid|
        migration_report = DulHydra::Migration::MigrationReport.where(fcrepo3_pid: pid).first
        if migration_report.model == "Item"
          unless migration_report.struct_metadata_status == MigrationReport::MIGRATION_SUCCESS
            Resque.enqueue(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, migration_report.fcrepo4_id)
          end
        end
      end
    end

  end
end
