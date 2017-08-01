class DatastreamUpload
  include ActiveModel::Model

  attr_accessor :checksum_path, :folder_path, :results, :user
  attr_reader :basepath, :checksum_file, :checksum_location, :collection_id, :configuration, :datastream_name, :subpath

  #Lifecycle events
  FINISHED = 'finished.datastream_upload'

  Results = Struct.new(:batch, :errors, :inspection_results)

  DEFAULT_CONFIG_FILE = Rails.root.join('config', 'datastream_upload.yml')

  validates_presence_of :basepath, :datastream_name, :subpath, :user
  validates_inclusion_of :datastream_name, in: [ Ddr::Datastreams::CAPTION,
                                                 Ddr::Datastreams::INTERMEDIATE_FILE,
                                                 Ddr::Datastreams::STREAMABLE_MEDIA ]
  validate :folder_directory_must_exist, if: [ 'basepath.present?', 'subpath.present?' ]
  validate :checksum_path_must_exist, if: 'checksum_file.present?'

  def self.default_config
    YAML.load(File.read(DEFAULT_CONFIG_FILE)).deep_symbolize_keys
  end

  def self.default_checksum_location(datastream_name)
    default_config[datastream_name.to_sym][:checksums][:location]
  end

  def self.default_basepaths(datastream_name)
    default_config[datastream_name.to_sym][:basepaths]
  end

  def initialize(args)
    @basepath = args['basepath']
    @checksum_file = args['checksum_file']
    @checksum_location = args['checksum_location']
    @collection_id = args['collection_id']
    @datastream_name = args['datastream_name']
    @subpath = args['subpath']
    @user = User.find_by_user_key(args['batch_user'])
    @configuration = self.class.default_config[datastream_name.to_sym]
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
        batch_description: filesystem.root.name,
        batch_name: "Datastream Upload",
        batch_user: user,
        datastream_name: datastream_name,
        filesystem: filesystem
    }
    builder_args.merge!(checksum_file_path: checksum_path) if checksum_file.present?
    builder_args.merge!(collection: collection_id) if collection_id
    batch_builder = BuildBatchFromDatastreamUpload.new(builder_args)
    batch_builder.call
  end

  def folder_directory_must_exist
    unless Dir.exist?(folder_path)
      errors.add(:subpath, "#{subpath} does not exist in #{basepath} or is not a directory")
    end
  end

  def checksum_path_must_exist
    unless File.exist?(checksum_path)
      errors.add(:checksum_file, "#{checksum_path} does not exist")
    end
  end

  def inspection_results
    @inspection_results ||= ScanFilesystem.new(folder_path, configuration[:scanner]).call
  end

  def filesystem
    @filesystem ||= inspection_results.filesystem
  end

  def folder_path
    @folder_path ||= File.join(basepath, subpath)
  end

  def checksum_path
    @checksum_path ||= File.join(checksum_location, checksum_file)
  end
end

