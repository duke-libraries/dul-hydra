class InspectStandardIngest

  attr_accessor :results
  attr_reader :scanner_config, :filepath, :datapath

  Results = Struct.new(:file_count, :exclusions, :content_model_stats, :filesystem)

  def initialize(filepath, scanner_config={})
    @scanner_config = scanner_config
    @filepath = filepath
    @datapath = File.join(filepath, 'data')
    @results = Results.new
  end

  def call
    inspect_filesystem
    results
  end

  private

  def inspect_filesystem
    validate_datapath
    scan_results = ScanFilesystem.new(datapath, scanner_config).call
    raise DulHydra::BatchError, "#{datapath} is not a valid standard ingest directory" unless standard_ingest_filesystem?(scan_results.filesystem)
    results.file_count = scan_results.filesystem.file_count
    results.exclusions = scan_results.exclusions
    results.content_model_stats = content_model_stats(scan_results.filesystem)
    results.filesystem = scan_results.filesystem
  end

  def scanner_configuration
    configuration[:scanner]
  end

  def validate_datapath
    raise DulHydra::BatchError, "#{datapath} not found or is not a directory" unless Dir.exist?(datapath)
    raise DulHydra::BatchError, "#{datapath} is not readable" unless File.readable?(datapath)
  end

  def content_model_stats(filesystem)
    collections = items = components = targets = 0
    filesystem.each do |n|
      case ModelStandardIngestContent.new(n, scanner_config[:intermediate_files], scanner_config[:targets]).call
        when 'Collection'
          collections += 1
        when 'Item'
          items += 1
        when 'Component'
          components += 1
        when 'Target'
          targets += 1
      end
    end
    { collections: collections, items: items, components: components, targets: targets }
  end

  def standard_ingest_filesystem?(filesystem)
    !filesystem.tree.each_leaf.any? { |leaf| leaf.node_depth != 2 }
  end


end
