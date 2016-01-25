module DulHydra::Migration
  class MigrateStructMetadata

    def self.migrate(limit=10)
      query(limit).result.pids.each do |pid|
        Resque.enqueue(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, pid)
      end
    end

    private

    def self.query(limit)
      builder = Ddr::Index::QueryBuilder.new do |bldr|
                  q "struct_maps_ssi:*info\\:fedora/duke\\:*"
                  limit limit
                end
      builder.query
    end

  end
end
