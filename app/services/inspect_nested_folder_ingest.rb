class InspectNestedFolderIngest

  attr_accessor :results
  attr_reader :scanner_config, :filepath

  Results = Struct.new(:file_count, :exclusions, :content_model_stats, :filesystem)

  def initialize(filepath, scanner_config={})
    @scanner_config = scanner_config
    @filepath = filepath
    @results = Results.new
  end

  def call
    inspect_filesystem
    results
  end

  private

  def inspect_filesystem
    validate_filepath
    scan_results = ScanFilesystem.new(filepath, scanner_config).call
    results.file_count = scan_results.filesystem.file_count
    results.exclusions = scan_results.exclusions
    results.content_model_stats = content_model_stats(scan_results.filesystem)
    results.filesystem = scan_results.filesystem
  end

  def scanner_configuration
    configuration[:scanner]
  end

  def validate_filepath
    raise DulHydra::BatchError, "#{filepath} not found or is not a directory" unless Dir.exist?(filepath)
    raise DulHydra::BatchError, "#{filepath} is not readable" unless File.readable?(filepath)
  end

  def content_model_stats(filesystem)
    collections = items = components = 0
    filesystem.each do |n|
      case ModelNestedFolderIngestContent.new(n).call
        when 'Collection'
          collections += 1
        when 'Component'
          items += 1
          components += 1
      end
    end
    { collections: collections, items: items, components: components }
  end

end
