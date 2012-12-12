module BatchIngestHelpers
  IDENTIFIER = "identifier"
  OBJECTS = "objects"
  def create_temp_dir
    @test_temp_dir = Dir.mktmpdir("dul_hydra_test")
  end
  def define_paths_and_files
    # Paths
    @ingest_base = "#{@test_temp_dir}#{File::SEPARATOR}ingest#{File::SEPARATOR}BASE#{File::SEPARATOR}"
    @manifest_base = "#{@ingest_base}manifests#{File::SEPARATOR}"
    @generic_base = "#{@ingest_base}generic#{File::SEPARATOR}"
    @collection_base = "#{@ingest_base}collection#{File::SEPARATOR}"
    @item_base = "#{@ingest_base}item#{File::SEPARATOR}"
    @component_base = "#{@ingest_base}component#{File::SEPARATOR}"
    @generic_master_base = "#{@generic_base}master#{File::SEPARATOR}"
    @collection_master_base = "#{@collection_base}master#{File::SEPARATOR}"
    @item_master_base = "#{@item_base}master#{File::SEPARATOR}"
    @component_master_base = "#{@component_base}master#{File::SEPARATOR}"
    @generic_marcxml_base = "#{@generic_base}marcXML#{File::SEPARATOR}"
    @generic_qdc_base = "#{@generic_base}qdc#{File::SEPARATOR}"
    # Filenames
    @manifest_filename = "manifest.yaml"
    @master_filename = "master.xml"
    # Fixture Filepaths
    @fixture_manifest_filepath = "spec/fixtures/batch_ingest/BASE/manifests/manifest.yaml" 
    @fixture_generic_master_filepath = "spec/fixtures/batch_ingest/BASE/generic/master/master.xml"
    @fixture_collection_master_filepath = "spec/fixtures/batch_ingest/BASE/collection/master/master.xml"
    @fixture_item_master_filepath = "spec/fixtures/batch_ingest/BASE/item/master/master.xml"
    @fixture_component_master_filepath = "spec/fixtures/batch_ingest/BASE/component/master/master.xml"
    @fixture_generic_marcxml_filepath = "spec/fixtures/batch_ingest/BASE/generic/marcXML/marcxml.xml"
    @fixture_generic_qdc_filepath = "spec/fixtures/batch_ingest/BASE/generic/qdc/qdc.xml"
  end
  def qdc_filenames(manifest_filepath)
    filenames = Array.new
    manifest = YAML::load(File.open(manifest_filepath))
    for object in manifest[OBJECTS]
      
      key_identifier = case object[IDENTIFIER]
      when String
        object[IDENTIFIER]
      when Array
        object[IDENTIFIER].first
      end
      filenames << "#{key_identifier}.xml"
    end
    return filenames
  end
  def update_manifest(manifest_filepath, attributes_hash)
    manifest = YAML::load(File.open(manifest_filepath))
    attributes_hash.each { |key, value| manifest[key] = value }
    File.open(manifest_filepath, "w") { |f| YAML::dump(manifest, f)}            
  end
  def remove_temp_dir
    FileUtils.remove_dir @test_temp_dir
  end
end
