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
    namespace :admin_policies do
        desc "Load admin policy objects from FILE_PATH"
	task :load => :environment do
	    raise "Must specify a config file. Ex: FILE_PATH=config/admin_policies.yml" unless ENV['FILE_PATH']
	    AdminPolicy.load_policies(ENV['FILE_PATH'])
	end
    end
    namespace :batch do
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
        desc "Make manifest MANIFEST based on files in directory DIRPATH"
        task :make_manifest => :environment do
            raise "Must specify directory path to files.  Ex.: DIRPATH=/nas/VOLUME/na_COL/" unless ENV['DIRPATH']
            raise "Must specify manifest.  Ex.: MANIFEST=/srv/fedora-working/ingest/COL/manifests/item.yml" unless ENV['MANIFEST']
            opts = { :dirpath => ENV['DIRPATH'], :manifest => ENV['MANIFEST'] }
            opts[:log_dir] = ENV['LOG_DIR'] if ENV['LOG_DIR']
            mm = DulHydra::Batch::Scripts::ManifestMaker.new(opts)
            mm.execute
        end
        desc "Create ingest batch objects from MANIFEST"
        task :process_manifest => :environment do
            raise "Must specify manifest.  Ex.: MANIFEST=/srv/fedora-working/ingest/COL/manifests/item.yml" unless ENV['MANIFEST']
            opts = { :manifest => ENV['MANIFEST'] }
            opts[:log_dir] = ENV['LOG_DIR'] if ENV['LOG_DIR']
            mp = DulHydra::Batch::Scripts::ManifestProcessor.new(opts)
            mp.execute
        end
        desc "Process ingest batch for BATCH_ID"
        task :process_ingest => :environment do
            raise "Must specify batch ID.  Ex.: BATCH_ID=7" unless ENV['BATCH_ID']
            opts = { :batch_id => ENV['BATCH_ID'] }
            opts[:log_dir] = ENV['LOG_DIR'] if ENV['LOG_DIR']
            bp = DulHydra::Batch::Scripts::BatchProcessor.new(opts)
            bp.execute
        end
        desc "Sets missing thumbnails in collection specified by COLLECTION_PID="
        task :thumbnails => :environment do
            raise "Must specify collection pid.  Ex: COLLECTION_PID=duke:72" unless ENV['COLLECTION_PID']
            thumb = DulHydra::Scripts::Thumbnails.new(ENV['COLLECTION_PID'])
            thumb.execute if thumb.collection
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
