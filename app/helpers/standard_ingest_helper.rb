module StandardIngestHelper

  # For convenience, for now, we assume that standard ingest will always use the default configuration file
  # (StandardIngest::DEFAULT_CONFIG_FILE), though StandardIngest is coded to permit passing in a different
  # config file.

  def permitted_standard_ingest_bases
    StandardIngest.default_basepaths
  end

end
