module StandardIngestHelper

  def standard_ingest_folder_options_for_select
    options_for_select(standard_ingest_folders.collect { |f| [ f, File.join(DulHydra.standard_ingest_base_path, f) ] }, @standard_ingest.folder_path)
  end

  def standard_ingest_folders
    base = DulHydra.standard_ingest_base_path
    Dir.entries(base).select {|e| File.directory? File.join(base, e) }.reject{ |e| e.starts_with?('.') }
  end

end
