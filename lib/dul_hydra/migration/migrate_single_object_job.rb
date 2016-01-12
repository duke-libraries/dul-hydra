module DulHydra::Migration
  class MigrateSingleObjectJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      FedoraMigrate::ObjectMover.new(
          FedoraMigrate.source.connection.find(id),
          nil,
          { convert: [ 'mergedMetadata' ] }
      ).migrate
    end

  end
end
