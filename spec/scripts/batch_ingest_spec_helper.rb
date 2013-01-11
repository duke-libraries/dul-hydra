module BatchIngestSpecHelper
  FIXTURES_BATCH_INGEST_BASE = "spec/fixtures/batch_ingest/BASE"
  def setup_test_temp_dir
    @test_temp_dir = Dir.mktmpdir("dul_hydra_test")
    ingest_base = "#{@test_temp_dir}/ingest"
    FileUtils.cp_r "#{FIXTURES_BATCH_INGEST_BASE}", "#{ingest_base}"
    return ingest_base
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
    manifest = File.open(manifest_filepath) { |f| YAML::load(f) }
    attributes_hash.each do |key, value|
      case
      when manifest[key].blank?
        manifest[key] = value
      when manifest[key].kind_of?(String)
        manifest[key] = value
      end
    end
    File.open(manifest_filepath, "w") { |f| YAML::dump(manifest, f)}            
  end
  def remove_temp_dir
    FileUtils.remove_dir @test_temp_dir
  end
end
