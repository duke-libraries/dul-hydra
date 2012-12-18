module BatchIngestSpecHelper
  def create_temp_dir
    @test_temp_dir = Dir.mktmpdir("dul_hydra_test")
  end
  def define_paths_and_files
    # Paths
    @ingest_base = "#{@test_temp_dir}#{File::SEPARATOR}ingest#{File::SEPARATOR}BASE#{File::SEPARATOR}"
    @manifest_base = "#{@ingest_base}manifests#{File::SEPARATOR}"
    @generic_base = "#{@ingest_base}generic#{File::SEPARATOR}"
    @generic_contentdm_base = "#{@generic_base}contentdm#{File::SEPARATOR}"
    @generic_digitizationguide_base = "#{@generic_base}digitizationguide#{File::SEPARATOR}"
    @generic_master_base = "#{@generic_base}master#{File::SEPARATOR}"
    @generic_marcxml_base = "#{@generic_base}marcxml#{File::SEPARATOR}"
    @generic_qdc_base = "#{@generic_base}qdc#{File::SEPARATOR}"
    # Filenames
    @manifest_filename = "manifest.yaml"
    @master_filename = "master.xml"
    # Fixture Paths and Filepaths
    @fixture_manifest_filepath = "spec/fixtures/batch_ingest/BASE/manifests/manifest.yaml" 
    @fixture_generic_contentdm_filepath = "spec/fixtures/batch_ingest/BASE/generic/contentdm/identifier_2.xml"
    @fixture_generic_digitizationguide_filepath = "spec/fixtures/batch_ingest/BASE/generic/digitizationguide/DigitizationGuide.xls"
    @fixture_generic_master_filepath = "spec/fixtures/batch_ingest/BASE/generic/master/master.xml"
    @fixture_generic_marcxml_filepath = "spec/fixtures/batch_ingest/BASE/generic/marcxml/marcxml.xml"
    @fixture_generic_qdc_base = "spec/fixtures/batch_ingest/BASE/generic/qdc/"
  end
  def qdc_filenames(manifest_filepath)
    filenames = Array.new
    File.open(manifest_filepath) { |f| @manifest = YAML::load(f) }
    for object in @manifest[:objects]
      unless object["qdcsource"].blank?
        key_identifier = case object[:identifier]
        when String
          object[:identifier]
        when Array
          object[:identifier].first
        end
        filenames << "#{key_identifier}.xml"
      end
    end
    return filenames
  end
  def update_manifest(manifest_filepath, attributes_hash)
    File.open(manifest_filepath) { |f| @manifest = YAML::load(f) }
    attributes_hash.each { |key, value| @manifest[key] = value }
    File.open(manifest_filepath, "w") { |f| YAML::dump(@manifest, f)}            
  end
  def remove_temp_dir
    FileUtils.remove_dir @test_temp_dir
  end
end
