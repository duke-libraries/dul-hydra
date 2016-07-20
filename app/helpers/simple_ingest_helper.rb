module SimpleIngestHelper

  def simple_ingest_folder_options_for_select
    options_for_select(simple_ingest_folders.collect { |f| [ f, File.join(DulHydra.simple_ingest_base_path, f) ] }, @simple_ingest.folder_path)
  end

  def simple_ingest_folders
    base = DulHydra.simple_ingest_base_path
    Dir.entries(base).select {|e| File.directory? File.join(base, e) }.reject{ |e| e.starts_with?('.') }
  end

end
