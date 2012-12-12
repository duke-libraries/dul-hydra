namespace :dul_hydra do
    namespace :batch do
        desc "Prepares a batch of objects for ingest based on a manifest file specified by MANIFEST="
        task :prepare_for_ingest => :environment do
            raise "Must specify a manifest file. Ex: MANIFEST='/srv/fedora-working/ingest/VIC/manifests/collection.yaml'" unless ENV['MANIFEST']
            DulHydra::Scripts::BatchIngest.prep_for_ingest(ENV['MANIFEST'])
        end
        desc "Ingests a batch of objects based on a manifest file specified by MANIFEST="
        task :ingest => :environment do
            raise "Must specify a manifest file. Ex: MANIFEST='/srv/fedora-working/ingest/VIC/manifests/collection.yaml'" unless ENV['MANIFEST']
            DulHydra::Scripts::BatchIngest.ingest(ENV['MANIFEST'])
        end
    end
    namespace :solr do
        desc "Deletes everything from the solr index"
        task :clean => :environment do
          Blacklight.solr.delete_by_query("*:*")
          Blacklight.solr.commit
        end
        desc "Index a single object in solr specified by PID="
        task :index => :environment do
          raise "Must specify a pid. Ex: PID='changeme:12'" unless ENV['PID']
          ActiveFedora::Base.connection_for_pid('foo:1') # Loads Rubydora connection with fake object
          ActiveFedora::Base.find(ENV['PID'], cast: true).update_index
        end
        desc 'Index all objects in the repository (except fedora-system: objects).'
        task :index_all => :environment do
          ActiveFedora::Base.connection_for_pid('foo:1') # Loads Rubydora connection with fake object
          ActiveFedora::Base.fedora_connection[0].connection.search(nil) do |object|
            if !object.pid.starts_with?('fedora-system:')
                ActiveFedora::Base.find(object.pid, cast: true).update_index
            end
          end
        end        
    end
end