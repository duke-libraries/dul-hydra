module DulHydra::Migration
  module Hooks

    def before_object_migration
      target.fcrepo3_pid = source.pid
      MultiresImageFilePath.new(self).migrate
    end

    def after_object_migration
      OriginalFilename.new(self).migrate
    end

    def before_rdf_datastream_migration
      if source.dsid == "adminMetadata"
        Roles.new(self).migrate
      end
    end

    def after_datastream_migration
      target.original_name = nil # fedora-migrate uses dsLabel to set original_name
    end

  end
end
