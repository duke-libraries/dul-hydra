class SimpleIngest
  include ActiveModel::Model

  attr_reader :admin_set, :collection_id, :config_file, :configuration, :folder_path
  attr_accessor :results, :user

  Results = Struct.new(:errors, :inspection_results)

  CHECKSUM_FILE = 'manifest-sha1.txt'
  DATA_DIRECTORY = 'data'
  DEFAULT_CONFIG_FILE = Rails.root.join('config', 'simple_ingest.yml')
  METADATA_FILE = 'metadata.txt'

  validates_presence_of(:folder_path, :user)
  with_options if: 'folder_path.present?' do |folder|
    folder.validate :folder_directory_must_exist
    folder.validate :data_directory_must_exist
    folder.validate :checksum_file_must_exist
    folder.validate :metadata_file_must_exist
  end
  validate :collection_must_exist, if: 'collection_id.present?'
  # folder path exists, is a directory, and is readable
  # folder path contains a data directory that is readable
  # folder contains sha-1 checksum file
  # data directory contains a metadata.txt file
  # process_simple_ingest
  # - throws DulHydra::BatchError if user cannot be found
  # - throws DulHydra::BatchError if unable to find collection
  # inspect_simple_ingest
  # - throws DulHydra::BatchError if scanned filesystem tree leaves not exactly two deep
  # - throws DulHydra::BatchError unless Dir.exist?(data-path)
  # - throws DulHydra::BatchError unless File.readable?(data-path)
  # model_simple_ingest_content
  # - throws DulHydra::BatchError if encounters node depth > 2
  # - throws DulHydra::BatchError if node depth is 2 and node has children
  # simple_ingest_metadata
  # - throws ArgumentError if invalid_headers

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
      inspection_results = InspectSimpleIngest.new(folder_path, configuration[:scanner]).call
      build_batch(inspection_results.filesystem)
    rescue DulHydra::BatchError => e
      processing_errors << e.message
    end
    results.inspection_results = inspection_results
    results.errors = processing_errors
    results
  end

  def build_batch(filesystem)
    batch_builder = BuildBatchFromFolderIngest.new(
        user,
        filesystem,
        ModelSimpleIngestContent,
        SimpleIngestMetadata.new(File.join(data_path, METADATA_FILE), configuration[:metadata]),
        SimpleIngestChecksum.new(File.join(folder_path, CHECKSUM_FILE)),
        "Simple Ingest",
        filesystem.root.name)
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

end
