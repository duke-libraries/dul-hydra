module DulHydra
  module Migration
    extend ActiveSupport::Autoload

    autoload :Hooks
    autoload :Migrator
    autoload :MultiresImageFilePath
    autoload :OriginalFilename
    autoload :Roles
  end
end
