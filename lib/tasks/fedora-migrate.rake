require "fedora-migrate"
require "dul_hydra/migration"

module FedoraMigrate::Hooks

  def before_object_migration
    DulHydra::Migration::SourceObjectIntegrity.new(self.source).verify
    target.fcrepo3_pid = source.pid
    DulHydra::Migration::MultiresImageFilePath.new(self).migrate
    DulHydra::Migration::RDFDatastreamMerger.new(self).merge
  end

  def after_object_migration
    DulHydra::Migration::OriginalFilename.new(self).migrate if target.can_have_content?
    DulHydra::Migration::TargetObjectIntegrity.new(self.source, self.target).verify
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

namespace :duke do
  namespace :migrate do
    desc "Migrate all my objects"
    task all: :environment do
      FedoraMigrate.migrate_repository(namespace: "duke",
                                       options: { convert: [ 'mergedMetadata' ] })
      DulHydra::Migration::MigrateStructMetadata.migrate
    end
    desc "Empty out the Fedora4 repository and migration reports"
    task reset: :environment do
      ActiveFedora::Cleaner.clean!
      DulHydra::Migration::MigrationReport.destroy_all
    end
    desc "Migrate a single object"
    task :object, [:pid] => :environment do |t, args|
      raise "Please provide a pid, example changeme:1234" if args[:pid].nil?
      Resque.enqueue(DulHydra::Migration::MigrateSingleObjectJob, (args[:pid]))
    end
    desc "Migrate the relationships for a single object"
    task :object_relationships, [:pid] => :environment do |t, args|
      raise "Please provide a pid, example changeme:1234" if args[:pid].nil?
      Resque.enqueue(DulHydra::Migration::MigrateSingleObjectRelationshipsJob, (args[:pid]))
    end
    desc "Migrate the structural metadata for a single object"
    task :object_struct_metadata, [:pid] => :environment do |t, args|
      raise "Please provide a pid, example changeme:1234" if args[:pid].nil?
      Resque.enqueue(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, (args[:pid]))
    end
    desc "Migrate list of objects"
    task :list_objects, [:pid_list_file_path] => :environment do |t, args|
      raise "Please a path to the pid list file, example pid_list.txt" if args[:pid_list_file_path].nil?
      DulHydra::Migration::MigrateListObjects.new(args[:pid_list_file_path]).migrate
    end
    desc "Migrate the relationships of list of objects"
    task :list_object_relationships, [:pid_list_file_path] => :environment do |t, args|
      raise "Please a path to the pid list file, example pid_list.txt" if args[:pid_list_file_path].nil?
      DulHydra::Migration::MigrateListObjectRelationships.new(args[:pid_list_file_path]).migrate
    end
    desc "Migrate the structural metadata of list of objects"
    task :list_object_struct_metadata, [:pid_list_file_path] => :environment do |t, args|
      raise "Please a path to the pid list file, example pid_list.txt" if args[:pid_list_file_path].nil?
      DulHydra::Migration::MigrateListObjectStructMetadata.new(args[:pid_list_file_path]).migrate
    end
  end
end

namespace :test do
  namespace :integration do
    desc "Run migration integration tests"
    task migration: :environment do
      system "rspec ./test/integration/migration/tests"
    end
  end
end
