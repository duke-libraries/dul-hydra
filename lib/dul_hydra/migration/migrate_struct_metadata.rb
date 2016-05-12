module DulHydra::Migration
  class MigrateStructMetadata

    def self.migrate(limit=10)
      query(limit).result.pids.each do |pid|
        Resque.enqueue(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, pid)
      end
    end

    private

    def self.query(limit)
      Ddr::Index::Query.new do
        q "#{Ddr::Index::Fields::STRUCT_MAPS}:*info\\:fedora*"
        fields :id
        limit limit
      end
    end

  end
end
