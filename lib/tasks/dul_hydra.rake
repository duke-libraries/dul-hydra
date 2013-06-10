namespace :dul_hydra do
    desc "CI build"
	task :ci do
		ENV['environment'] = "test"
		jetty_params = Jettywrapper.load_config
  		jetty_params[:startup_wait] = 60
        Jettywrapper.wrap(jetty_params) do
    	    Rake::Task['spec'].invoke
		end
	end
    desc "Copy sample DULHydra config files into appropriate places"
	task :config => :environment do
	    FileList['config/*.sample'].each do |f|
		    copy_to = f.sub(/\.sample$/, "")
		    if File.exists?(copy_to)
			    puts "Config file \"#{copy_to}\" exists, not overwriting."
			else
			    cp(f, copy_to, :verbose => true)
			end
		end
	end
    namespace :admin_policies do
        desc "Load admin policy objects from FILE_PATH"
	task :load => :environment do
	    raise "Must specify a config file. Ex: FILE_PATH=config/admin_policies.yml" unless ENV['FILE_PATH']
	    AdminPolicy.load_policies(ENV['FILE_PATH'])
	end
    end
    namespace :batch do
        desc "Updates KWL item contentMetadata datastreams with PDFs"
        task :update_kwl_contentmetadata => :environment do
            DulHydra::Scripts::UpdateKwlContentMetadata.execute
        end
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
        desc "Performs post-ingest processing on a batch of objects based on a manifest file specified by MANIFEST="
        task :post_ingest => :environment do
            raise "Must specify a manifest file. Ex: MANIFEST='/srv/fedora-working/ingest/VIC/manifests/item.yaml'" unless ENV['MANIFEST']
            DulHydra::Scripts::BatchIngest.post_process_ingest(ENV['MANIFEST'])
        end
        desc "Validates the ingest of a batch of objects based on a manifest file specified by MANIFEST="
        task :validate_ingest => :environment do
            raise "Must specify a manifest file. Ex: MANIFEST='/srv/fedora-working/ingest/VIC/manifests/item.yaml'" unless ENV['MANIFEST']
            DulHydra::Scripts::BatchIngest.validate_ingest(ENV['MANIFEST'])
        end
        desc "Runs the fixity check routine"
        task :fixity_check => :environment do
            opts = {
                :dryrun => ENV['dryrun'] == 'true' ? true : false,
                :limit => ENV.fetch('limit', 1000).to_i,
                :period => ENV.fetch('period', '60DAYS'),
				:report => ENV['report']
            }
	    	mailto = ENV['mailto']
            puts "Running batch fixity check with options #{opts} ..."
            bfc = DulHydra::Scripts::BatchFixityCheck.new(opts)
	    	bfc.execute
	    	BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
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