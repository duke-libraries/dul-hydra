module DulHydra
  module Migration
    extend ActiveSupport::Autoload

    autoload :CollectionMigration
    autoload :MigrationMetadata
    autoload :MigrationMetadataTable

  end
end
