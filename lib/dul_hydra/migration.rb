module DulHydra
  module Migration
    extend ActiveSupport::Autoload

    autoload :MigratedObjectFinder
    autoload :Migrator
    autoload :MultiresImageFilePath
    autoload :OriginalFilename
    autoload :RDFDatastreamMerger
    autoload :Roles
    autoload :MigrateListObjects
    autoload :MigrateListObjectRelationships
    autoload :MigrateSingleObjectJob
    autoload :MigrateSingleObjectRelationshipsJob
    autoload :SourceObjectIntegrity
    autoload :TargetObjectIntegrity
  end
end
