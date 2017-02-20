class StandardIngest
  include ActiveModel::Model

  attr_reader :admin_set, :collection_id, :config_file, :configuration, :folder_path
  attr_accessor :results, :user

  Results = Struct.new(:errors, :inspection_results)

  CHECKSUM_FILE = 'manifest-sha1.txt'
  DATA_DIRECTORY = 'data'
  DEFAULT_CONFIG_FILE = Rails.root.join('config', 'standard_ingest.yml')
  METADATA_FILE = 'metadata.txt'

  validates_presence_of(:folder_path, :user)
  with_options if: 'folder_path.present?' do |folder|
    folder.validate :folder_directory_must_exist
    folder.validate :data_directory_must_exist
    folder.validate :checksum_file_must_exist
    folder.validate :metadata_file_must_exist, unless: 'collection_id.present?'
    folder.validate :validate_metadata_file, if: 'File.exist?(metadata_path)'
  end
  validate :collection_must_exist, if: 'collection_id.present?'

  def initialize(args)
    @admin_set = args['admin_set']
    @collection_id = args['collection_id']
    @config_file = args['config_file'] || DEFAULT_CONFIG_FILE.to_s
    @configuration = load_configuration
    @folder_path = args['folder_path']
    @user = User.find_by_user_key(args['batch_user'])
    @results = Results.new
  end

  def process
    processing_errors = []
    begin
      build_batch
    rescue DulHydra::BatchError => e
      processing_errors << e.message
    end
    results.inspection_results = inspection_results
    results.errors = processing_errors
    results
  end

  def build_batch
    builder_args = {
        user: user,
        filesystem: filesystem,
        targets_name: configuration[:scanner][:targets],
        content_modeler: ModelStandardIngestContent,
        checksum_provider: StandardIngestChecksum.new(File.join(folder_path, CHECKSUM_FILE)),
        batch_name: "Standard Ingest",
        batch_description: filesystem.root.name
    }
    if File.exist?(metadata_path)
      builder_args.merge!(metadata_provider: StandardIngestMetadata.new(metadata_path, configuration[:metadata]))
    end
    builder_args.merge!(admin_set: admin_set) if admin_set
    builder_args.merge!(collection_repo_id: collection_id) if collection_id
    batch_builder = BuildBatchFromFolderIngest.new(builder_args)
    batch = batch_builder.call
  end

  def collection_must_exist
    unless Collection.exists?(collection_id)
      errors.add(:collection_id, 'must point to existing collection')
    end
  end

  def folder_directory_must_exist
    unless Dir.exist?(folder_path)
      errors.add(:folder_path, "does not exist or is not a directory")
    end
  end

  def data_directory_must_exist
    unless Dir.exist?(data_path)
      errors.add(:folder_path, "#{data_path} does not exist or is not a directory")
    end
  end

  def checksum_file_must_exist
    unless File.exist?(checksum_path)
      errors.add(:folder_path, "#{checksum_path} does not exist")
    end
  end

  def metadata_file_must_exist
    unless File.exist?(metadata_path)
      errors.add(:folder_path, "#{metadata_path} does not exist")
    end
  end

  def validate_metadata_file
    misses = metadata_provider.locators.select { |locator| !filesystem_node_paths.include?(locator) }
    misses.each { |miss| errors.add(:metadata_file, "Metadata line for locator '#{miss}' will not be used")}
  end

  def load_configuration
    YAML::load(File.read(config_file)).symbolize_keys
  end

  def data_path
    @data_path ||= File.join(folder_path, DATA_DIRECTORY)
  end

  def checksum_path
    @checksum_path ||= File.join(folder_path, CHECKSUM_FILE)
  end

  def metadata_path
    @metadata_path ||= File.join(data_path, METADATA_FILE)
  end

  def metadata_provider
    @metadata_provider ||= StandardIngestMetadata.new(File.join(data_path, METADATA_FILE), configuration[:metadata])
  end

  def inspection_results
    @inspection_results ||= InspectStandardIngest.new(folder_path, configuration[:scanner]).call
  end

  def filesystem
    @filesystem ||= inspection_results.filesystem
  end

  def filesystem_node_paths
    @filesystem_node_paths ||= filesystem.each.map { |node| Filesystem.node_locator(node) }
  end

end
