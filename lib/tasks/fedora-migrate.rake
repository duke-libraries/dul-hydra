require "fedora-migrate"
require "dul_hydra/migration"

module FedoraMigrate::Hooks

  def before_object_migration
    target.fcrepo3_pid = source.pid
    DulHydra::Migration::MultiresImageFilePath.new(self).migrate
    DulHydra::Migration::RDFDatastreamMerger.new(self).merge
  end

  def after_object_migration
    DulHydra::Migration::OriginalFilename.new(self).migrate if target.can_have_content?
  end

  def before_rdf_datastream_migration
    if source.dsid == "mergedMetadata"
      DulHydra::Migration::Roles.new(self).migrate
    end
  end

  def after_datastream_migration
    target.original_name = nil # fedora-migrate uses dsLabel to set original_name
  end

end

desc "Migrate all my objects"
task migrate: :environment do
  FedoraMigrate.migrate_repository(namespace: "duke",
                                   options: { convert: [ 'mergedMetadata' ] })
end

namespace :test do
  namespace :integration do
    desc "Run migration integration tests"
    task migration: :environment do
      system "rspec ./test/integration/migration/tests"
    end
  end
end
