class NestedFolderIngest
  include ActiveModel::Model

  attr_reader :admin_set, :basepath, :checksum_file, :collection_id, :collection_title, :config_file, :configuration,
              :metadata_file, :subpath, :folder_path
  attr_accessor :results, :user

  # Lifecycle events
  FINISHED = 'finished.nested_folder_ingest'

  Results = Struct.new(:batch, :errors, :inspection_results)

  DEFAULT_CONFIG_FILE = Rails.root.join('config', 'nested_folder_ingest.yml')

  validates_presence_of :basepath, :checksum_file, :subpath, :user
  validate :folder_directory_must_exist, if: [ 'basepath.present?', 'subpath.present?' ]
  validate :collection_must_exist, if: 'collection_id.present?'
  validates_presence_of :admin_set, :collection_title, unless: 'collection_id.present?'
  validate :checksum_file_must_exist, if: 'checksum_file.present?'
  validate :metadata_file_must_exist, if: 'metadata_file.present?'
  validate :validate_metadata_file, if: [ 'metadata_file.present?', 'File.exist?(metadata_path)' ]

  def self.default_config
    YAML.load(File.read(DEFAULT_CONFIG_FILE)).deep_symbolize_keys
  end

  def self.default_checksum_location
    default_config[:checksums][:location]
  end

  def self.default_metadata_location
    default_config[:metadata][:location]
  end

  def self.default_basepaths
    default_config[:basepaths]
  end

  def initialize(args)
    @admin_set = args['admin_set']
    @basepath = args['basepath']
    @checksum_file = args['checksum_file']
    @collection_id = args['collection_id']
    @collection_title = args['collection_title']
    @config_file = args['config_file'] || DEFAULT_CONFIG_FILE.to_s
    @configuration = load_configuration
    @metadata_file = args['metadata_file']
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
        content_modeler: ModelNestedFolderIngestContent,
        batch_name: "Nested Folder Ingest",
        batch_description: filesystem.root.name
    }
    builder_args.merge!(checksum_provider: IngestChecksum.new(checksum_path)) if checksum_file
    builder_args.merge!(admin_set: admin_set) if admin_set
    builder_args.merge!(collection_repo_id: collection_id) if collection_id
    builder_args.merge!(collection_title: collection_title) if collection_title
    builder_args.merge!(metadata_provider: IngestMetadata.new(metadata_path, configuration[:metadata])) if metadata_file
    batch_builder = BuildBatchFromNestedFolderIngest.new(builder_args)
    batch_builder.call
  end

  def collection_must_exist
    unless Collection.exists?(collection_id)
      errors.add(:collection_id, 'must point to existing collection')
    end
  end

  def folder_directory_must_exist
    unless Dir.exist?(folder_path)
      errors.add(:subpath, "#{subpath} does not exist in #{basepath} or is not a directory")
    end
  end

  def checksum_file_must_exist
    unless File.exist?(checksum_path)
      errors.add(:checksum_file, "#{checksum_path} does not exist")
    end
  end

  def metadata_file_must_exist
    unless File.exist?(metadata_path)
      errors.add(:metadata_file, "#{metadata_path} does not exist")
    end
  end

  def validate_metadata_file
    misses = metadata_provider.locators.select { |locator| !filesystem_node_paths.include?(locator) }
    misses.each { |miss| errors.add(:metadata_file,
                                    I18n.t('dul_hydra.nested_folder_ingest.validation.missing_file', miss: miss)) }
  rescue ArgumentError => e
    errors.add(:metadata_file, e.message)
  end

  def load_configuration
    YAML.load(File.read(config_file)).deep_symbolize_keys
  end

  def basepaths
    @basepaths ||= configuration[:basepaths]
  end

  def checksum_path
    @checksum_path ||= File.join(configuration[:checksums][:location], checksum_file)
  end

  def metadata_path
    @metadata_path ||= File.join(configuration[:metadata][:location], metadata_file)
  end

  def metadata_provider
    @metadata_provider ||= IngestMetadata.new(metadata_path, configuration[:metadata])
  end

  def folder_path
    @folder_path ||= File.join(basepath, subpath)
  end

  def inspection_results
    @inspection_results ||= InspectNestedFolderIngest.new(folder_path, configuration[:scanner]).call
  end

  def filesystem
    @filesystem ||= inspection_results.filesystem
  end

  def filesystem_node_paths
    @filesystem_node_paths ||= filesystem.each.map { |node| Filesystem.path_to_node(node) } + [ nil ]
  end

end
