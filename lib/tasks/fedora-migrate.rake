desc "Migrate all my objects"
task migrate: :environment do
  FedoraMigrate.migrate_repository(namespace: "duke",
                                   options: { convert: [ 'descMetadata', 'adminMetadata' ] })
end