require 'dul_hydra/version'

namespace :dul_hydra do

  desc "Print the version string of the app"
  task :version do
    puts DulHydra::VERSION
  end

  desc "Tag version v#{DulHydra::VERSION}"
  task :tag do
    require 'open3'
    v = DulHydra::VERSION
    puts "Tagging version v#{v} ..."
    stdout, stderr, status = Open3.capture3("git tag -a v#{v} -m \"DulHydra v#{v}\"")
    if status.success?
      puts stdout unless stdout.blank?
      puts "Pushing tag v#{v} to origin ..."
      `git push origin v#{v}`
    else
      puts "ERROR: #{stderr}"
    end
  end

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
    desc "Creates ingest batch from Simple Ingest Format directory"
    task :simple_ingest => :environment do
      raise "Must specify folder path. Ex.: FOLDER=/path/to/simple/ingest/folder" unless ENV['FOLDER']
      raise "Must specify batch user.  Ex.: BATCH_USER=tom@school.edu" unless ENV['BATCH_USER']
      processor_args = { filepath: ENV['FOLDER'] }
      processor_args[:config_file] = ENV['CONFIG_FILE'] if ENV['CONFIG_FILE']
      processor_args[:batch_user] = ENV['BATCH_USER']
      processor = DulHydra::Batch::Scripts::ProcessSimpleIngest.new(processor_args)
      processor.execute
    end
    desc "Creates descriptive metadata update batch from folder of METS files"
    task :mets_folder => :environment do
      raise "Must specify folder path. Ex.: FOLDER=/path/to/METS/folder" unless ENV['FOLDER']
      operator_key = "#{ENV['USER']}@duke.edu"
      operator = User.find_by_user_key(operator_key)
      batch_user = ENV['BATCH_USER'].present? ? User.find_by_user_key(ENV['BATCH_USER']) : operator
      unless batch_user.present?
        raise "Unable to find batch user: #{ENV['BATCH_USER'].present? ? ENV['BATCH_USER'] : operator_key}"
      end
      args = {
        folder: ENV['FOLDER'],
        batch_user: batch_user,
        collection: ENV['COLLECTION']
      }
      script = DulHydra::Batch::Scripts::MetadataFolderProcessor.new(args)
      script.scan
      options = {}
      options['p'] = "Create pending batch"
      options['s'] = "Create batch and submit for processing" if operator.present?
      options['x'] = "Cancel operation"
      options.each { |k, v| STDOUT.puts "#{k} - #{v}" }
      input = ""
      while true do
        STDOUT.print "Enter #{options.keys.join(', ')} : "
        input = STDIN.gets.strip
        unless options.include?(input.downcase)
          next
        end
        case input.downcase
        when "p"
          batch = script.create_batch
          STDOUT.puts "Created pending batch #{batch.id} for user #{args[:user]}"
        when "s"
          STDOUT.puts "Creating batch and submitting for processing"
          batch = script.create_batch
          STDOUT.puts "Created batch #{batch.id} for user #{args[:user]}"
          Resque.enqueue(DulHydra::Batch::Jobs::BatchProcessorJob, batch.id, operator.id)
          STDOUT.puts "Submitted batch #{batch.id} for processing"
        when "x"
          STDOUT.puts "Cancelling operation"
        end
        break
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

  namespace :index do
    desc "Deletes everything from the Solr index"
    task :clean => :environment do
      Blacklight.solr.delete_by_query("*:*")
      Blacklight.solr.commit
    end
    desc "Index a single object in Solr specified by PID="
    task :update => :environment do
      raise "Must specify a pid. Ex: PID=changeme:12" unless ENV["PID"]
      ActiveFedora::Base.find(ENV["PID"]).update_index
    end
    desc "Index all objects in the repository (except fedora-system: objects)."
    task :update_all => :environment do
      conn = ActiveFedora::RubydoraConnection.new(ActiveFedora.config.credentials).connection
      conn.search(nil) do |object|
        next if object.pid.start_with?('fedora-system:')
        Resque.enqueue(DulHydra::Jobs::UpdateIndex, object.pid)
      end
      puts "All repository objects queued for indexing."
    end
  end

  namespace :validate do
    desc "Run model validation on all objects in the repository"
    task :all => :environment do
      ActiveFedora::Base.find_each do |obj|
        print "Validating #{obj.pid} ... "
        puts obj.valid? ? Ddr::Events::Event::VALID : Ddr::Events::Event::INVALID
      end
    end
  end

  namespace :queues do
    task :interrupt, [:signal] do |t, args|
      pid_file = File.join(Rails.root, "tmp/pids/resque-pool.pid")
      pid = `cat #{pid_file}`
      system "kill -#{args[:signal]} #{pid}"
    end

    desc "Start the queue pool manager and workers"
    task :start => :environment do
      system "resque-pool --daemon --environment #{Rails.env}"
    end

    desc "Stop the pool manager and workers"
    task :stop => :environment do
      Rake::Task["dul_hydra:queues:interrupt"].invoke("QUIT")
    end

    desc "Restart the pool manager and workers"
    task :restart => :environment do
      Rake::Task["dul_hydra:queues:interrupt"].invoke("HUP")
    end
  end

end
