module DulHydra
  module Migration
    extend ActiveSupport::Autoload

    autoload :MigratedObjectFinder
    autoload :Migrator
    autoload :MultiresImageFilePath
    autoload :OriginalFilename
    autoload :RDFDatastreamMerger
    autoload :Roles
  end
end
