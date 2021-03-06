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

  desc "Destroy object listed in file, one PID per line, and their descendants"
  task :destroy_objects, [:infile] => :environment do |t, args|
    pids = File.readlines(args[:infile]).map(&:chomp)
    print "#{pids.length} objects and their descendants will be destroyed! Proceed? [y/N] "
    if STDIN.gets.strip == 'y'
      puts "Destroying objects!"
      DestroyObjectsAndDescendants.call(pids)
    else
      puts "Task aborted."
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
    desc "Adds intermediate files to existing Components"
    task :intermediate_files => :environment do
      raise "Must specify folder path to intermediate files. Ex.: FOLDER=/path/to/files" unless ENV["FOLDER"]
      raise "Must specify batch user.  Ex.: BATCH_USER=tom@school.edu" unless ENV['BATCH_USER']
      processor_args = { filepath: ENV['FOLDER'], batch_user: ENV['BATCH_USER'] }
      processor_args[:checksum_file] = ENV['CHECKSUM_FILE'] if ENV['CHECKSUM_FILE']
      processor = DulHydra::Batch::Scripts::AddIntermediateFiles.new(processor_args)
      processor.execute
    end
    desc "Adds streamable media files to existing Components"
    task :streamable_media_files => :environment do
      raise "Must specify folder path to streamable media files. Ex.: FOLDER=/path/to/files" unless ENV["FOLDER"]
      raise "Must specify batch user.  Ex.: BATCH_USER=tom@school.edu" unless ENV['BATCH_USER']
      processor_args = { filepath: ENV['FOLDER'], batch_user: ENV['BATCH_USER'] }
      processor_args[:checksum_file] = ENV['CHECKSUM_FILE'] if ENV['CHECKSUM_FILE']
      processor = DulHydra::Batch::Scripts::AddStreamableMediaFiles.new(processor_args)
      processor.execute
    end
    desc "Creates ingest batch from Standard Ingest Format directory"
    task :standard_ingest => :environment do
      raise "Must specify folder path. Ex.: FOLDER=/path/to/standard/ingest/folder" unless ENV['FOLDER']
      raise "Must specify batch user.  Ex.: BATCH_USER=tom@school.edu" unless ENV['BATCH_USER']
      raise "Cannot specify both ADMIN_SET and COLLECTION_PID" if ENV['ADMIN_SET'] && ENV['COLLECTION_PID']
      job_args = { folder_path: ENV['FOLDER'] }
      job_args[:batch_user] = ENV['BATCH_USER']
      job_args[:admin_set] = ENV['ADMIN_SET'] if ENV['ADMIN_SET']
      job_args[:collection_id] = ENV['COLLECTION_PID'] if ENV['COLLECTION_PID']
      job_args[:config_file] = ENV['CONFIG_FILE'] if ENV['CONFIG_FILE']
      Resque.enqueue(StandardIngestJob, job_args)
    end
    desc "Creates update batch from folder of METS files"
    task :mets_folder => :environment do
      raise "Must specify folder path. Ex.: FOLDER=/path/to/METS/folder" unless ENV['FOLDER']
      raise "Must specify batch user.  Ex.: BATCH_USER=tom@school.edu" unless ENV['BATCH_USER']
      raise "Must specify collection PID.  Ex: COLLECTION_PID=duke:72" unless ENV['COLLECTION_PID']
      processor_args = { folder: ENV['FOLDER'] }
      processor_args[:batch_user] = ENV['BATCH_USER']
      processor_args[:collection_pid] = ENV['COLLECTION_PID']
      processor_args[:config_file] = ENV['CONFIG_FILE'] if ENV['CONFIG_FILE']
      processor = DulHydra::Batch::Scripts::ProcessMETSFolder.new(processor_args)
      processor.execute
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
    desc "Sets missing thumbnails in collection specified by COLLECTION_PID="
    task :thumbnails => :environment do
      raise "Must specify collection pid.  Ex: COLLECTION_PID=duke:72" unless ENV['COLLECTION_PID']
      thumb = DulHydra::Scripts::Thumbnails.new(ENV['COLLECTION_PID'])
      thumb.execute if thumb.collection
    end
  end

  namespace :fixity do
    desc "Run batch fixity check routine"
    task :check => :environment do
      args = {}
      if ENV["before_days"]
        args[:before_days] = ENV["before_days"].to_i
      end
      if ENV["limit"]
        args[:limit] = ENV["limit"].to_i
      end
      puts "Running fixity check with args #{args.inspect}."
      BatchFixityCheck.call(**args)
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

    desc "Re-index all currently indexed objects"
    task :reindex_all => :environment do
      Ddr::Index.pids.each do |pid|
        Resque.enqueue(UpdateIndexJob, pid)
      end
      puts "All indexed object queued for re-indexing."
    end

    desc "Index all objects in the repository (except fedora-system: objects)."
    task :update_all => :environment do
      conn = ActiveFedora::RubydoraConnection.new(ActiveFedora.config.credentials).connection
      conn.search(nil) do |object|
        next if object.pid.start_with?('fedora-system:')
        Resque.enqueue(UpdateIndexJob, object.pid)
      end
      puts "All repository objects queued for indexing."
    end

    desc "Re-index the contents of a collection"
    task :collection_contents, [:pid] => :environment do |t, args|
      ReindexCollectionContents.call(args[:pid])
      puts "Collection contents have been queued for re-indexing."
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
    desc "Report the status of the pool manager"
    task :status => :environment do
      puts "The pool manager is #{DulHydra::Queues.running? ? 'running' : 'stopped'}."
    end

    desc "Start the queue pool manager and workers"
    task :start => :environment do
      if DulHydra::Queues.start
        puts "Starting pool manager and workers."
      else
        puts "Error attempting to start pool manager and workers (may already be running)."
      end
    end

    desc "Stop the pool manager and workers"
    task :stop => :environment do
      if DulHydra::Queues.stop
        puts "Shutting down workers and pool manager."
      else
        puts "Error attempting to shut down workers and pool manager (may not be running)."
      end
    end

    desc "Restart (stop/start) the pool manager and workers"
    task :restart => :environment do
      if DulHydra::Queues.restart
        puts "Restarting pool manager and workers."
      else
        puts "Error attempting to restart pool manager and workers."
      end
    end

    desc "Reload the pool manager config and restart workers"
    task :reload => :environment do
      if DulHydra::Queues.reload
        puts "Reloading pool manager config and restarting workers."
      else
        puts "Error attempting to reload pool manager config and restart workers."
      end
    end
  end

  desc "Run FITS file characterization process on content files"
  task :characterize_files, [:limit] => :environment do |t, args|
    queued = BatchFileCharacterization.call(args[:limit])
    puts "#{queued} FITS file characterization job(s) submitted for processing."
  end

  namespace :roles do
    desc "Grant policy role on collections in admin set"
    task :grant_policy_role_in_admin_set => :environment do
      raise "Must specify admin set. Ex.: ADMIN_SET=foo" unless ENV['ADMIN_SET']
      raise "Must specify role.  Ex.: ROLE=Downloader" unless ENV['ROLE']
      raise "Must specify agent.  Ex: AGENT=tom@school.edu" unless ENV['AGENT']
      colls = Collection.where(Ddr::Index::Fields::ADMIN_SET => ENV['ADMIN_SET'])
      colls.each do |coll|
        coll.roles.grant role_type: ENV['ROLE'], scope: "policy", agent: ENV['AGENT']
        coll.save!
      end
      puts "#{ENV['AGENT']} granted the #{ENV['ROLE']} role in policy scope on #{colls.count} collection(s)."
    end
  end

  namespace :thumbnail do
    desc "Copy thumbnail from one object to another"
    task :copy, [:source_id, :target_id] => :environment do |t, args|
      source_obj = ActiveFedora::Base.find(args[:source_id])
      target_obj = ActiveFedora::Base.find(args[:target_id])
      if target_obj.copy_thumbnail_from(source_obj)
        target_obj.save!
        puts "Thumbanil copied from source #{source_obj.id} to target #{target_obj.id}."
      else
        puts "ERROR: Thumbnail not found on source #{source_obj.id}."
      end
    end

    desc "Upload thumbnail for an object"
    task :upload, [:file, :target_id] => :environment do |t, args|
      target_obj = ActiveFedora::Base.find(args[:target_id])
      File.open(args[:file], "rb") do |file|
        target_obj.thumbnail.content = file
        target_obj.thumbnail.mimeType = Ddr::Utils.mime_type_for(file)
        if target_obj.save
          puts "File #{file.path} uploaded as thumbnail for #{target_obj.id}."
        else
          puts "ERROR: Thumbnail not updated."
        end
      end
    end
  end

  namespace :permanent_id do
    desc "Assign permanent IDs to objects which do not have one"
    task :assign, [:limit] => :environment do |t, args|
      rows = args[:limit] || 100
      query = Ddr::Index::Query.build(rows.to_i) do |r|
        absent :permanent_id
        limit r
      end
      query.each_id do |repo_id|
        Resque.enqueue(AssignPermanentIdJob, repo_id)
      end
      puts "Queued #{query.count} permanent ID assignment jobs."
    end
  end

end
