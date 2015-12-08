desc "Migrate all my objects"
task migrate: :environment do
  FedoraMigrate.migrate_repository(namespace: "duke",
                                   options: { convert: [ 'descMetadata', 'adminMetadata' ] })
end

namespace :test do
  namespace :integration do
    desc "Run migration integration tests"
    task migration: :environment do
      system "rspec ./test/integration/migration/tests"
    end
  end
end
