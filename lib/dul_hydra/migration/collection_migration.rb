module DulHydra
  module Migration
    module CollectionMigration

      class << self
        def call(collection_pid, path_to_file_to_write)
          pids = [ collection_pid ] +
                    associated_pids(collection_pid, 'Item') +
                    associated_pids(collection_pid, 'Component') +
                    associated_pids(collection_pid, 'Attachment') +
                    associated_pids(collection_pid, 'Target')
          migration_metadata_table = MigrationMetadataTable.new(pids)
          migration_metadata_table.write_to_file(path_to_file_to_write)
        end

        def associated_pids(collection_pid, model)
          query = Ddr::Index::Query.new do
            is_governed_by "info:fedora/#{collection_pid}"
            model model
          end
          query.ids.to_a
        end
      end

    end
  end
end
