class StandardIngest
  include ActiveModel::Model

  attr_reader :admin_set, :basepath, :collection_id, :config_file, :configuration, :subpath
  attr_accessor :results, :user

  # Lifecycle events
  FINISHED = 'finished.standard_ingest'

  Results = Struct.new(:batch, :errors, :inspection_results)

  CHECKSUM_FILE = 'manifest-sha1.txt'
  DATA_DIRECTORY = 'data'
  DEFAULT_CONFIG_FILE = Rails.root.join('config', 'standard_ingest.yml')
  METADATA_FILE = 'metadata.txt'

  validates_presence_of(:basepath, :subpath, :user)
  with_options if: 'folder_path.present?' do |folder|
    folder.validate :folder_directory_must_exist
    folder.validate :data_directory_must_exist
    folder.validate :valid_standard_ingest_directory
    folder.validate :checksum_file_must_exist
    folder.validate :metadata_file_must_exist, unless: 'collection_id.present?'
    folder.validate :validate_metadata_file, if: 'File.exist?(metadata_path)'
  end
  validate :collection_must_exist, if: 'collection_id.present?'
  validates_presence_of(:admin_set, unless: 'collection_id.present?')

  def self.default_config
    YAML.load(File.read(DEFAULT_CONFIG_FILE)).deep_symbolize_keys
  end

  def self.default_basepaths
    default_config[:basepaths]
  end

  def initialize(args)
    @admin_set = args['admin_set']
    @basepath = args['basepath']
    @collection_id = args['collection_id']
    @config_file = args['config_file'] || DEFAULT_CONFIG_FILE.to_s
    @configuration = load_configuration
    @subpath = args['subpath']
    @user = User.find_by_user_key(args['batch_user'])
    @results = Results.new
  end

  def process
    processing_errors = []
    begin
      results.batch = build_batch
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
        intermediate_files_name: configuration[:scanner][:intermediate_files],
        targets_name: configuration[:scanner][:targets],
        content_modeler: ModelStandardIngestContent,
        checksum_provider: StandardIngestChecksum.new(File.join(folder_path, CHECKSUM_FILE)),
        batch_name: "Standard Ingest",
        batch_description: filesystem.root.name
    }
    if File.exist?(metadata_path)
      builder_args.merge!(metadata_provider: IngestMetadata.new(metadata_path, configuration[:metadata]))
    end
    builder_args.merge!(admin_set: admin_set) if admin_set
    builder_args.merge!(collection_repo_id: collection_id) if collection_id
    batch_builder = BuildBatchFromStandardIngest.new(builder_args)
    batch_builder.call
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

  def valid_standard_ingest_directory
    begin
      inspection_results
    rescue DulHydra::BatchError => e
      errors.add(:folder_path, e.message)
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
    misses.each { |miss| errors.add(:metadata_file,
                                    I18n.t('dul_hydra.standard_ingest.validation.missing_folder_file', miss: miss)) }
  rescue ArgumentError => e
    errors.add(:metadata_file, e.message)
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
    @metadata_provider ||= IngestMetadata.new(File.join(data_path, METADATA_FILE), configuration[:metadata])
  end

  def folder_path
    @folder_path ||= File.join(basepath, subpath)
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
