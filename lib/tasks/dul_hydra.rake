namespace :dul_hydra do
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
