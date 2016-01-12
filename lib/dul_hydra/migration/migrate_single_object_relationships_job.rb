module DulHydra::Migration
  class MigrateSingleObjectRelationshipsJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.source.connection.find(id)).migrate
    end

  end
end
