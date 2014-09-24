namespace :dul_hydra do

    namespace :config do
      desc "Copy sample config files" 
      task :samples do
          Dir.glob("config/**/*.sample") do |sample|
            actual = sample.gsub(/\.sample/, "")
            FileUtils.cp sample, actual, verbose: true unless File.exists?(actual)
          end
      end
    end

    namespace :ci do
      desc "Prepare for CI build"
      task :prepare => ['dul_hydra:config:samples', 'db:test:prepare', 'jetty:clean', 'jetty:config'] do
      end

      desc "CI build"
      task :build => :prepare do
        ENV['environment'] = "test"
        jetty_params = Jettywrapper.load_config
        jetty_params[:startup_wait] = 60
        Jettywrapper.wrap(jetty_params) do
            Rake::Task['spec'].invoke
        end
      end
    end

    namespace :batch do
      desc "Creates descriptive metadata update batch from folder of METS files"
      task :mets_folder => :environment do
        raise "Must specify folder path. Ex.: FOLDER=/path/to/METS/folder" unless ENV['FOLDER']
        operator = User.find_by_user_key("#{ENV['USER']}@duke.edu")
        batch_user = ENV['USER_KEY'] || operator.user_key
        args = {
          folder: ENV['FOLDER'],
          user: batch_user,
          collection: ENV['COLLECTION']
        }
        script = DulHydra::Batch::Scripts::MetadataFolderProcessor.new(args)
        script.scan
        STDOUT.puts "p - Create pending batch"
        STDOUT.puts "s - Create batch and submit for processing"
        STDOUT.puts "x - Cancel operation"
        input = ""
        while ![ "P", "p", "S", "s", "X", "x" ].include?(input) do
          STDOUT.print "Enter p, s, or x : "
          input = STDIN.gets.strip
          case input
          when "P", "p"
            batch = script.create_batch
            STDOUT.puts "Created pending batch #{batch.id} for user #{args[:user]}"
          when "S", "s"
            STDOUT.puts "Creating batch and submitting for processing"
            batch = script.create_batch
            STDOUT.puts "Created batch #{batch.id} for user #{args[:user]}"
            Resque.enqueue(DulHydra::Batch::Jobs::BatchProcessorJob, batch.id, operator.id)
            STDOUT.puts "Submitted batch #{batch.id} for processing"
          when "X", "x"
            STDOUT.puts "Cancelling operation"
          end
        end
      end
      desc "Converts CSV file to one or more XML files"
      task :csv_to_xml => :environment do
        raise "Must specify CSV file.  Ex.: csv=/srv/fedora-working/ingest/COL/cdm/export.csv" unless ENV['csv']
        raise "Must specify XML file or directory path.  Ex.: csv=/srv/fedora-working/ingest/COL/cdm/export.xml" unless ENV['xml']
        opts = {
          :csv => ENV['csv'],
          :xml => ENV['xml'],
          :profile => ENV['profile'],
          :schema_map => ENV['schema_map']
        }
        script = DulHydra::Scripts::CsvToXml.new(opts)
        script.execute
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
          if bfc.total > 0
            BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
          end
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

    namespace :validate do
	    desc "Run model validation on all objects in the repository"
        task :all => :environment do
            ActiveFedora::Base.find_each do |obj|
                print "Validating #{obj.pid} ... "
                puts obj.valid? ? Event::VALID : Event::INVALID
            end
        end
    end
end
