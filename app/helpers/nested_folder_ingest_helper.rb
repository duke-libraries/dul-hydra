module NestedFolderIngestHelper

  # For convenience, for now, we assume that nested folder ingest will always use the default configuration file
  # (NestedFolderIngest::DEFAULT_CONFIG_FILE), though NestedFolderIngest is coded to permit passing in a different
  # config file.

  def checksum_location
    NestedFolderIngest.default_checksum_location
  end

  def permitted_folder_bases
    NestedFolderIngest.default_basepaths
  end

  def checksum_files
    Dir.entries(checksum_location).select { |e| File.file?(File.join(checksum_location, e)) }
  end

  def checksum_files_options_for_select
    options_for_select(checksum_files.collect { |f| [ f, f ] }, @nested_folder_ingest.checksum_file)
  end

end
