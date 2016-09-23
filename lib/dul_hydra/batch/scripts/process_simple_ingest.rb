module DulHydra::Batch::Scripts

  class ProcessSimpleIngest

    attr_reader :batch_user, :configuration, :filepath, :admin_set, :collection_id

    CHECKSUM_FILE = 'manifest-sha1.txt'
    METADATA_FILE = 'metadata.txt'
    DEFAULT_CONFIG_FILE = Rails.root.join('config', 'simple_ingest.yml')
    DEFAULT_ARGUMENTS = { config_file: DEFAULT_CONFIG_FILE }

    def initialize(args=DEFAULT_ARGUMENTS)
      @batch_user = User.find_by_user_key(args.fetch(:batch_user))
      raise DulHydra::BatchError, "Unable to find user #{args.fetch(:batch_user)}" unless @batch_user.present?
      verify_collection_id if @collection_id = args[:collection_id]
      @configuration = load_configuration(args.fetch(:config_file, DEFAULT_CONFIG_FILE))
      @filepath = args.fetch(:filepath)
    end

    def execute
      inspection_results = inspect_filepath
      user_choice = prompt_user
      case user_choice
      when 'p'
        batch = build_batch(inspection_results.filesystem)
        puts "Created pending batch #{batch.id} for user #{batch.user.user_key}"
      when 'x'
        puts "Cancelling operation"
      end
    end

    private

    def verify_collection_id
      begin
        Collection.find(collection_id)
      rescue ActiveFedora::ObjectNotFoundError
        raise DulHydra::BatchError, "Unable to find collection #{collection_id}"
      end
    end

    def load_configuration(config_file)
      YAML::load(File.read(config_file)).symbolize_keys
    end

    def inspect_filepath
      results = InspectSimpleIngest.new(filepath, configuration[:scanner]).call
      puts "Inspected #{results.filesystem.root.name}"
      puts "Found #{results.file_count} files"
      unless results.exclusions.empty?
        puts "Excluding #{results.exclusions.join(', ')}"
      end
      puts "Content models #{model_stats(results.content_model_stats)}"
      results
    end

    def model_stats(content_model_stats)
      if collection_id
        content_model_stats.except!(:collections)
      end
      content_model_stats
    end

    def prompt_user
      options = user_options
      options.each { |k, v| puts "#{k} - #{v}" }
      get_user_choice(options)
    end

    def user_options
      options = {}
      options['p'] = "Create pending batch"
      options['x'] = "Cancel operation"
      options
    end

    def get_user_choice(options=user_options)
      input = ""
      while true do
        print "Enter #{options.keys.join(', ')} : "
        input = STDIN.gets.strip
        break if options.keys.include?(input.downcase)
      end
      input.downcase
    end

    def build_batch(filesystem)
      batch_builder = BuildBatchFromFolderIngest.new(
                          user: batch_user,
                          filesystem: filesystem,
                          content_modeler: ModelSimpleIngestContent,
                          metadata_provider: SimpleIngestMetadata.new(File.join(filepath, 'data', METADATA_FILE),
                                                                      configuration[:metadata]),
                          checksum_provider: SimpleIngestChecksum.new(File.join(filepath, CHECKSUM_FILE)),
                          admin_set: admin_set,
                          collection_repo_id: collection_id,
                          batch_name: "Simple Ingest",
                          batch_description: filesystem.root.name)
      batch = batch_builder.call
    end

  end
end
