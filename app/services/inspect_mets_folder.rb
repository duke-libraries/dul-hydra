class InspectMETSFolder

  attr_accessor :results
  attr_reader :mets_folder, :collection, :scanner_config

  Results = Struct.new(:file_count, :exclusions, :filesystem, :warnings, :errors)

  def initialize(mets_folder, mets_folder_config = METSFolderConfiguration.new)
    @mets_folder = mets_folder
    @collection = ActiveFedora::Base.find(mets_folder.collection_id)
    @scanner_config = mets_folder_config.scanner_config
    @results = Results.new
  end

  def call
    inspect_folder
    results
  end

  private

  def inspect_folder
    validate_folderpath
    scan_results = ScanFilesystem.new(mets_folder.full_path, scanner_config).call
    raise DulHydra::BatchError, "#{mets_folder.full_path} does not appear to be a valid METS folder" unless mets_folder?(scan_results.filesystem)
    results.warnings, results.errors = validate_mets_files(scan_results.filesystem)
    results.file_count = scan_results.filesystem.file_count
    results.exclusions = scan_results.exclusions
    results.filesystem = scan_results.filesystem
  end

  def validate_folderpath
    raise DulHydra::BatchError, "#{mets_folder.full_path} not found or is not a directory" unless Dir.exist?(mets_folder.full_path)
    raise DulHydra::BatchError, "#{mets_folder.full_path} is not readable" unless File.readable?(mets_folder.full_path)
  end

  def mets_folder?(filesystem)
    !filesystem.tree.each_leaf.any? { |leaf| File.extname(leaf.name) != '.xml' }
  end

  def validate_mets_files(filesystem)
    warnings = []
    errors = []
    filesystem.tree.each_leaf do |leaf|
      mets_file = METSFile.new(Filesystem.path_to_node(leaf), collection)
      validation_results = ValidateMETSFile.new(mets_file).call
      warnings += validation_results.warnings
      errors += validation_results.errors
    end
    [ warnings, errors ]
  end

end
