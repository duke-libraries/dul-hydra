module DulHydra::Migration
  class MigrateSingleObjectStructMetadataJob
    extend Ddr::Jobs::Job

    @queue = :migration

    def self.perform(id)
      obj = ActiveFedora::Base.find(id)
      DulHydra::Migration::StructMetadata.new(obj).migrate
    end

  end
end
