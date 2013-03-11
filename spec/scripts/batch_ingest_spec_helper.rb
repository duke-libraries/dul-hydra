require 'find'

module BatchIngestSpecHelper
  FIXTURES_BATCH_INGEST_BASE = "spec/fixtures/batch_ingest/BASE"
  
  def setup_test_dir
    @test_dir = Dir.mktmpdir("dul_hydra_test")
    base_dir = "#{@test_dir}/ingest/BASE"
    @manifest_dir = "#{base_dir}/manifests"
    FileUtils.mkdir_p @manifest_dir
    @ingestable_dir = "#{base_dir}/ingestable"
    FileUtils.mkdir_p @ingestable_dir
    FileUtils.mkdir "#{@ingestable_dir}/log"
  end
  def remove_test_dir
    FileUtils.remove_dir @test_dir
  end
  def locate_datastream_content_file(location_pattern)
    locations = []
    Find.find('jetty/fedora/test/data/datastreamStore/') do |f|
      if f.match("#{location_pattern}")
        locations << f
      end
    end
    return locations
  end
  def update_manifest(manifest_filepath, attributes_hash)
    manifest = File.open(manifest_filepath) { |f| YAML::load(f) }
    attributes_hash.each do |key, value|
      manifest[key] = value
    end
    File.open(manifest_filepath, "w") { |f| YAML::dump(manifest, f)}            
  end
  def remove_temp_dir
    FileUtils.remove_dir @test_temp_dir
  end
  def create_expected_content_metadata_document
      expected = Nokogiri::XML::Document.new
      root = Nokogiri::XML::Node.new "mets", expected
      expected.root = root
      expected.root.default_namespace = 'http://www.loc.gov/METS/'
      expected.root.add_namespace_definition 'xlink', 'http://www.w3.org/1999/xlink'
      fileSec = Nokogiri::XML::Node.new "fileSec", expected
      fileGrp = Nokogiri::XML::Node.new "fileGrp", expected
      fileGrp['ID'] = 'GRP01'
      fileGrp['USE'] = 'Master Image'
      file1 = Nokogiri::XML::Node.new "file", expected
      file1['ID'] = 'FILE001'
      fLocat1 = Nokogiri::XML::Node.new "FLocat", expected
      fLocat1['xlink:href'] = "#{@component3.pid}/content"
      fLocat1['LOCTYPE'] = 'URL'
      file1.add_child(fLocat1)
      file2 = Nokogiri::XML::Node.new "file", expected
      file2['ID'] = 'FILE002'
      fLocat2 = Nokogiri::XML::Node.new "FLocat", expected
      fLocat2['xlink:href'] = "#{@component1.pid}/content"
      fLocat2['LOCTYPE'] = 'URL'
      file2.add_child(fLocat2)
      file3 = Nokogiri::XML::Node.new "file", expected
      file3['ID'] = 'FILE003'
      fLocat3 = Nokogiri::XML::Node.new "FLocat", expected
      fLocat3['xlink:href'] = "#{@component2.pid}/content"
      fLocat3['LOCTYPE'] = 'URL'
      file3.add_child(fLocat3)
      fileGrp.add_child(file1)
      fileGrp.add_child(file2)
      fileGrp.add_child(file3)
      fileSec.add_child(fileGrp)
      expected.root.add_child(fileSec)
      structMap = Nokogiri::XML::Node.new "structMap", expected
      div0 = Nokogiri::XML::Node.new "div", expected
      div0['ID'] = 'DIV01'
      div0['TYPE'] = 'image'
      div0['LABEL'] = 'Images'
      div11 = Nokogiri::XML::Node.new "div", expected
      div11['ORDER'] = '1'
      fptr11 = Nokogiri::XML::Node.new "fptr", expected
      fptr11['FILEID'] = 'FILE001'
      div11.add_child(fptr11)
      div12 = Nokogiri::XML::Node.new "div", expected
      div12['ORDER'] = '2'
      fptr12 = Nokogiri::XML::Node.new "fptr", expected
      fptr12['FILEID'] = 'FILE002'
      div12.add_child(fptr12)
      div13 = Nokogiri::XML::Node.new "div", expected
      div13['ORDER'] = '3'
      fptr13 = Nokogiri::XML::Node.new "fptr", expected
      fptr13['FILEID'] = 'FILE003'
      div13.add_child(fptr13)
      div0.add_child(div11)
      div0.add_child(div12)
      div0.add_child(div13)
      structMap.add_child(div0)
      expected.root.add_child(structMap)
      return expected
  end
end
