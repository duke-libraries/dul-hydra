require 'spec_helper'
require 'fileutils'
require "#{Rails.root}/spec/scripts/batch_ingest_spec_helper"

RSpec.configure do |c|
  c.include BatchIngestSpecHelper
end

module DulHydra::Scripts

  FIXTURES_BATCH_INGEST = "spec/fixtures/batch_ingest"

  shared_examples "an ingested batch" do  
    let(:expected_identifiers) { [ ["id001"], ["id002", "id003"], ["id004"] ] }
    let(:expected_label) { "Manifest Label" }
    let(:expected_desc_metadata_label) { "Descriptive Metadata for this object" }
    it "should be in the repository with a descMetadata datastream" do
      found_identifiers = []
      object_type.find_each do |object|
        object.admin_policy.should eq(admin_policy)
        object.label.should eq(expected_label)
        object.descMetadata.label.should eq(expected_desc_metadata_label)
        object.descMetadata.content.should_not be_empty
        found_identifiers << object.identifier
      end
      found_identifiers.sort.should eq(expected_identifiers.sort)
    end
    it "should have the object PID's in the master file" do
      master.xpath("/objects/object").each do |object|
        identifier = object.xpath("identifier").first.content
        object.xpath("pid").should_not be_empty
        pid = object.xpath("pid").first.content
        repo_object = object_type.find(pid)
        repo_object.identifier.should include(identifier)
      end
    end
    it "should have an ingestion preservation event for each object" do
      object_type.find_each do |object|
        events = object.preservation_events
        ingestion_events = []
        events.each do |event|
          if event.event_type == PreservationEvent::INGESTION
            ingestion_events << event
          end
        end
        ingestion_events.size.should eq(1)
        ingestion_event = ingestion_events.first
        DateTime.strptime(ingestion_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
        DateTime.strptime(ingestion_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
        ingestion_event.event_outcome.should == PreservationEvent::SUCCESS
        ingestion_event.linking_object_id_type.should eq(PreservationEvent::OBJECT)
        ingestion_event.linking_object_id_value.should eq(object.internal_uri)
        ingestion_event.event_detail.should include("Identifier(s): #{object.identifier.flatten.join(',')}")
        ingestion_event.event_outcome_detail_note.should include(object.pid)
      end
    end
    it "should have a ingestion log file" do
      log_file.should match("DulHydra version #{DulHydra::VERSION}")
      log_file.should match("Manifest: #{manifest}")
      object_type.find_each do |object|
        log_file.should match("Ingested #{object_type.to_s} #{object.identifier.first} into #{object.pid}")
      end
    end
  end
  
  shared_examples "an ingested batch with files" do
    let(:expected_content_label) { "Content file for this object" }
    let(:expected_contentdm_label) { "CONTENTdm Data for this object" }
    let(:expected_digitization_guide_label) { "Digitization Guide Data for this object" }
    let(:expected_dpc_metadata_label) { "DPC Metadata for this object" }
    let(:expected_fmp_export_label) { "FileMakerPro Export Data for this object" }
    let(:expected_marc_xml_label) { "Aleph MarcXML Data for this object" }
    let(:expected_tripod_mets_label) { "Tripod METS Data for this object" }
    it "should have the appropriate datastreams" do
      object_type.find_each do |object|
        object.content.label.should eq(expected_content_label)
        FileUtils.compare_stream(StringIO.new(object.content.content), StringIO.new(tif_file)).should be_true
        object.contentdm.label.should eq(expected_contentdm_label)
        FileUtils.compare_stream(StringIO.new(object.contentdm.content), StringIO.new(xml_file)).should be_true
        object.digitizationGuide.label.should eq(expected_digitization_guide_label)
        FileUtils.compare_stream(StringIO.new(object.digitizationGuide.content), StringIO.new(xls_file)).should be_true
        object.dpcMetadata.label.should eq(expected_dpc_metadata_label)
        FileUtils.compare_stream(StringIO.new(object.dpcMetadata.content), StringIO.new(xml_file)).should be_true
        object.fmpExport.label.should eq(expected_fmp_export_label)
        FileUtils.compare_stream(StringIO.new(object.fmpExport.content), StringIO.new(xml_file)).should be_true
        object.marcXML.label.should eq(expected_marc_xml_label)
        FileUtils.compare_stream(StringIO.new(object.marcXML.content), StringIO.new(xml_file)).should be_true
        object.tripodMets.label.should eq(expected_tripod_mets_label)
        FileUtils.compare_stream(StringIO.new(object.tripodMets.content), StringIO.new(xml_file)).should be_true
      end
    end
  end
  
  shared_examples "an ingested batch with content" do
    it "should have a creator and source" do
      object_type.find_each do |object|
        object.creator.first.should eq(content_creator)
        object.source.first.should eq(content_source)
      end
    end
  end
  
  shared_examples "an ingested batch with image content" do
    it "should have a thumbnail" do
      object_type.find_each do |object|
        object.thumbnail.content.should_not be_nil
        object.thumbnail.mimeType.should eq("image/png")
      end
    end
  end
  
  shared_examples "a child object" do
    it "should have the correct parent object" do
      object_type.find_each do |object|
        object.parent.should eq(parents[object.identifier.first])
      end
    end
  end
  
  shared_examples "a target object" do
    it "should be associated with a collection" do
      Target.find_each do |target|
        target.collection.should eq(collection)
      end
    end
  end
  
  shared_examples "a validated ingest" do
    before do
      @passes = 0
      @fails = 0
      results.values.each { |value| value.eql?("PASS") ? @passes += 1 : @fails += 1 }
      @overall_result =  @fails.eql?(0) ? "PASS" : "FAIL"
    end
    it "should have an ingest validation log file" do
      log_file.should_not be_empty
      log_file.should match("DulHydra version #{DulHydra::VERSION}")
      log_file.should match("Manifest: #{manifest}")
      results.each do |key, value|
        log_file.should match("Validated #{object_type.to_s} #{key} in .*...#{value}")
      end
      log_file.should match("Validated #{results.size} object\\(s\\)")
      log_file.should match("PASS: #{@passes}")
      log_file.should match("FAIL: #{@fails}")
      log_file.should match("Validation ...#{@overall_result}")
    end
  end
  
  shared_examples "a validated ingest with repository objects" do
    let(:outcomes) { Hash[ "PASS" => PreservationEvent::SUCCESS, "FAIL" => PreservationEvent::FAILURE ] }
    it "should have ingest validation preservation events" do
      object_type.find_each do |object|
        events = object.preservation_events
        validation_events = []
        events.each do |event|
          if event.event_type == PreservationEvent::VALIDATION
            validation_events << event
          end
        end
        validation_events.size.should eq(1)
        validation_event = validation_events.first
        DateTime.strptime(validation_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
        DateTime.strptime(validation_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
        validation_event.event_outcome.should == outcomes[results[object.identifier.first]]
        validation_event.linking_object_id_type.should eq(PreservationEvent::OBJECT)
        validation_event.linking_object_id_value.should eq(object.internal_uri)
        validation_event.event_outcome_detail_note.should include("Identifier(s): #{object.identifier.flatten.join(',')}")
        case outcomes[results[object.identifier.first]]
        when PreservationEvent::SUCCESS
          validation_event.event_outcome_detail_note.should include("PASS")
          validation_event.event_outcome_detail_note.should_not include("FAIL")
          validation_event.event_outcome_detail_note.should include("VALIDATES")
        when PreservationEvent::FAILURE
          validation_event.event_outcome_detail_note.should include("FAIL")
          validation_event.event_outcome_detail_note.should include("DOES NOT VALIDATE")
          if !details.blank?
            validation_event.event_outcome_detail_note.should include(details[object.identifier.first])
          end
        end
      end
    end
  end
  
  shared_examples "a validated ingest with content" do
    let(:outcomes) { Hash[ "PASS" => PreservationEvent::SUCCESS, "FAIL" => PreservationEvent::FAILURE ] }
    it "should have fixity check preservation events" do
      object_type.find_each do |object|
        fixity_check_events = object.fixity_checks
        fixity_check_events.to_a.size.should eq(1)
        fixity_check_event = fixity_check_events.first
        DateTime.strptime(fixity_check_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
        DateTime.strptime(fixity_check_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
        fixity_check_event.event_outcome.should == outcomes[results[object.identifier.first]]
      end
    end
  end

  describe BatchIngest do
    before do
      setup_test_dir
    end
    after do
      remove_test_dir
    end
    describe "prepare for ingest" do
      before do
        FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/base_manifest.yml", "#{@manifest_dir}/manifest.yml"
        @manifest_file = "#{@manifest_dir}/manifest.yml"
        update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
      end
      context "all object types" do
        it "should create an appropriate master file" do
            DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
            result = File.open("#{@ingestable_dir}/master/master.xml") { |f| Nokogiri::XML(f) }
            expected = File.open("#{FIXTURES_BATCH_INGEST}/master/base_master.xml") { |f| Nokogiri::XML(f) }
            result.should be_equivalent_to(expected)
        end
        it "should create Qualified Dublin Core files" do
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          File.size?("#{@ingestable_dir}/descmetadata/id001.xml").should_not be_nil
          File.size?("#{@ingestable_dir}/descmetadata/id002.xml").should_not be_nil
          File.size?("#{@ingestable_dir}/descmetadata/id004.xml").should_not be_nil
        end
        it "should create an appropriate log file" do
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          result = File.open("#{@ingestable_dir}/log/ingest_preparation.log") { |f| f.read }
          result.should match("DulHydra version #{DulHydra::VERSION}")
          result.should match("Manifest: #{@manifest_file}")
          result.should match("Processing id001")
          result.should match("Processing id002")
          result.should match("Processing id004")
          result.should match("Processed 3 object\\(s\\)")
        end
      end
      context "partially populated master file already exists" do
        before do
          FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/preexisting_master.xml", "#{@ingestable_dir}/master/master.xml"
        end
        it "should add the new objects to those already in the master file" do
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
            result = File.open("#{@ingestable_dir}/master/master.xml") { |f| Nokogiri::XML(f) }
            expected = File.open("#{FIXTURES_BATCH_INGEST}/master/base_added_to_preexisting_master.xml") { |f| Nokogiri::XML(f) }
            result.should be_equivalent_to(expected)
        end
      end
      context "consolidated file is to be split into individual files" do
        before do
          FileUtils.mkdir "#{@ingestable_dir}/a_test"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/composite_to_be_split.xml", "#{@ingestable_dir}/a_test"
          split_entry = Array.new
          split_entry << HashWithIndifferentAccess.new(
            :type => "a_test",
            :source => "composite_to_be_split.xml",
            :xpath => "/metadata/record",
            :idelement => "localid"
          )
          update_manifest(@manifest_file, {"split" => split_entry})
        end
        it "should split the consolidated file into appropriate individual files" do
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          result_1 = File.open("#{@ingestable_dir}/a_test/test010010010.xml") { |f| Nokogiri::XML(f) }
          result_2 = File.open("#{@ingestable_dir}/a_test/test010010020.xml") { |f| Nokogiri::XML(f) }
          result_3 = File.open("#{@ingestable_dir}/a_test/test010010030.xml") { |f| Nokogiri::XML(f) }
          expected_1 = Nokogiri::XML("<record><Title>Title 1</Title><Date>1981-01</Date><localid>test010010010</localid></record>")
          expected_2 = Nokogiri::XML("<record><Title>Title 2</Title><Date>1987-09</Date><localid>test010010020</localid></record>")
          expected_3 = Nokogiri::XML("<record><Title>Title 3</Title><Date>1979-11</Date><localid>test010010030</localid></record>")
          result_1.should be_equivalent_to(expected_1)
          result_2.should be_equivalent_to(expected_2)
          result_3.should be_equivalent_to(expected_3)
        end
      end
    end
    describe "ingest" do
      let!(:admin_policy) { AdminPolicy.create(:pid => "duke-apo:adminPolicy") }
      let(:log_file) { File.open("#{@ingestable_dir}/log/batch_ingest.log") { |f| f.read } }
      let(:manifest) { @manifest_file }
      let(:master) { File.open("#{@ingestable_dir}/master/master.xml") { |f| Nokogiri::XML(f) } }
      before do
        FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
        FileUtils.cp "spec/fixtures/batch_ingest/master/base_master.xml", "#{@ingestable_dir}/master/master.xml"
        FileUtils.mkdir_p(File.join(@ingestable_dir, 'descmetadata')) unless File.exists?(File.join(@ingestable_dir, 'descmetadata'))
        FileUtils.cp "spec/fixtures/batch_ingest/descmetadata/id001.xml", "#{@ingestable_dir}/descmetadata"
        FileUtils.cp "spec/fixtures/batch_ingest/descmetadata/id002.xml", "#{@ingestable_dir}/descmetadata"
        FileUtils.cp "spec/fixtures/batch_ingest/descmetadata/id004.xml", "#{@ingestable_dir}/descmetadata"
      end
      after do
        object_type.find_each do |object|
          object.preservation_events.each { |pe| pe.delete }
          object.reload
          object.delete
        end
        admin_policy.delete
      end
      context "any ingested object" do
        let(:object_type) { TestModel }
        before do
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/base_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          update_manifest(@manifest_file, {:model => object_type.to_s})
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        it_behaves_like "an ingested batch"
      end
      context "files to be ingested" do
        let(:object_type) { TestFileDatastreams }
        let(:tif_file) { File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/id001.tif") { |f| f.read } }
        let(:xls_file) { File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xls") { |f| f.read } }
        let(:xml_file) { File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml") { |f| f.read } }
        before do
          FileUtils.mkdir "#{@ingestable_dir}/contentdm"
          FileUtils.mkdir "#{@ingestable_dir}/digitizationguide"
          FileUtils.mkdir "#{@ingestable_dir}/dpcmetadata"
          FileUtils.mkdir "#{@ingestable_dir}/fmpexport"
          FileUtils.mkdir "#{@ingestable_dir}/marcxml"
          FileUtils.mkdir "#{@ingestable_dir}/tripodmets"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/contentdm/"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xls", "#{@ingestable_dir}/digitizationguide/"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/dpcmetadata/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/fmpexport/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/marcxml/"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/tripodmets/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/manifest_with_files.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        it_behaves_like "an ingested batch with files"
      end
      context "image content to be ingested" do
        let(:object_type) { TestContentThumbnail }
        let(:content_creator) { "DPC" }
        let(:content_source) { "BASE/ingestable/content/id001.tif" }
        before do
          FileUtils.mkdir "#{@ingestable_dir}/content"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/id001.tif", "#{@ingestable_dir}/content"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/content_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          update_manifest(@manifest_file, {"content" => {
                              "extension" => ".tif",
                              "location" => "#{@ingestable_dir}/content/",
                              "creator" => "DPC",
                              "pathroot" => "BASE/"
                              } })
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        it_behaves_like "an ingested batch with content"
        it_behaves_like "an ingested batch with image content"
      end
      context "child object" do
        let(:object_type) { TestChild }
        let!(:parents) do
          Hash[
               "id001" => FactoryGirl.create(:test_parent, :identifier => "id0"),
               "id002" => FactoryGirl.create(:test_parent, :identifier => "parent01")
              ]
        end
        before do
          FileUtils.cp File.join(FIXTURES_BATCH_INGEST, 'manifests', 'child_manifest.yml'), File.join(@manifest_dir, 'manifest.yml')
          @manifest_file = File.join(@manifest_dir, 'manifest.yml')
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          update_manifest(@manifest_file, {:model => object_type.to_s})
          parent_master = create_supporting_master(parents.values)
          @parent_dir = Dir.mktmpdir("dul_hydra_test_parent")
          File.open(File.join(@parent_dir, 'manifest.xml'), 'w') { |f| parent_master.write_xml_to f }
          update_manifest(@manifest_file, {:parent => {:master => File.join(@parent_dir, 'manifest.xml')}})
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        after do
          parents.values.each do |parent|
            parent.delete
          end
          FileUtils.remove_dir @parent_dir
        end
        it_behaves_like "a child object"
      end
      context "Target" do
        context "target has associated collection" do
          let(:object_type) { Target }
          let!(:collection) { FactoryGirl.create(:collection, :identifier => "collection_1") }
          before do
            FileUtils.cp File.join(FIXTURES_BATCH_INGEST, 'manifests', 'target_manifest.yml'), File.join(@manifest_dir, 'manifest.yml')
            @manifest_file = File.join(@manifest_dir, 'manifest.yml')
            update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
            collection_master = create_supporting_master([collection])
            @collection_dir = Dir.mktmpdir("dul_hydra_test_collection")
            File.open(File.join(@collection_dir, 'manifest.xml'), 'w') { |f| collection_master.write_xml_to f }
            update_manifest(@manifest_file, {:collection => {:master => File.join(@collection_dir, 'manifest.xml')}})
            DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
          end
          after do
            collection.delete
            FileUtils.remove_dir @collection_dir
          end
          it_behaves_like "a target object"
        end
      end
    end
    describe "post-process ingest" do
      let(:object_type) { TestContentMetadata }
      let(:log_file) { File.open("#{@ingestable_dir}/log/ingest_postprocess.log") { |f| f.read } }
      let(:manifest) { @manifest_file }
      let(:master) { File.open("#{@ingestable_dir}/master/master.xml") { |f| f.read } }
      before do
        FileUtils.mkdir "#{@ingestable_dir}/contentmetadata"
        FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/contentstructure_manifest.yml", "#{@manifest_dir}/manifest.yml"
        @manifest_file = "#{@manifest_dir}/manifest.yml"
        update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
        FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
        FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/base_master_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
        @parent = TestContentMetadata.create!(:pid => 'test:1', :identifier => 'id001')
        @child1 = TestChild.create!(:identifier => 'id00100030')
        @child2 = TestChild.create!(:identifier => 'id00100010')
        @child3 = TestChild.create!(:identifier => 'id00100020')
        @child1.parent = @parent
        @child2.parent = @parent
        @child3.parent = @parent
        @child1.save!
        @child2.save!
        @child3.save!
      end
      after do
        @child1.delete
        @child2.delete
        @child3.delete
        @parent.delete
      end
      context "content structural metadata" do
        let(:expected_xml) { create_expected_content_metadata_document.to_xml}
        it "should add an appropriate contentMetadata datastream to the parent object" do
          DulHydra::Scripts::BatchIngest.post_process_ingest(@manifest_file)
          @parent.reload
          @parent.contentMetadata.content.should be_equivalent_to(expected_xml)
        end
        it "should create an appropriate log file" do
          DulHydra::Scripts::BatchIngest.post_process_ingest(@manifest_file)
          result = File.open("#{@ingestable_dir}/log/ingest_postprocess.log") { |f| f.read }
          result.should match("DulHydra version #{DulHydra::VERSION}")
          result.should match("Manifest: #{@manifest_dir}/manifest.yml")
          result.should match("Added contentmetadata datastream for id001 to test:1")
          result.should match("Post-processed 1 object\\(s\\)")
        end
      end
    end
    describe "validate ingest" do
      let!(:admin_policy) { AdminPolicy.create(:pid => "duke-apo:adminPolicy") }
      let(:log_file) { File.open("#{@ingestable_dir}/log/ingest_validation.log") { |f| f.read } }
      let(:manifest) { @manifest_file }
      let(:master) { File.open("#{@ingestable_dir}/master/master.xml") { |f| Nokogiri::XML(f) } }
      after do
        admin_policy.delete  
      end
      context "any batch ingest" do
        let(:object_type) { TestModel }
        before do
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/base_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/base_master_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
          @objects = [
                      TestModel.create(:pid => "test:1", :identifier => "id001"),
                      TestModel.create(:pid => "test:2", :identifier => "id002"),
                      TestModel.create(:pid => "test:3", :identifier => "id004")
                      ]
        end
        after do
          @objects.each do |object|
            begin
              object.preservation_events.each { |pe| pe.delete }
              object.reload
              object.delete
            rescue ActiveFedora::ObjectNotFoundError
              next
            end
          end
        end
        context "ingest is valid" do
          let(:results) { Hash[ "id001" => "PASS", "id002" => "PASS", "id004" => "PASS" ] }
          before do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
          end
          it_behaves_like "a validated ingest"
          it_behaves_like "a validated ingest with repository objects"
        end
        context "ingest is invalid" do
          context "unable to obtain pid from master file" do
            let(:results) { Hash[ "id001" => "FAIL", "id002" => "PASS", "id004" => "FAIL" ] }
            before do
              master = File.open("#{@ingestable_dir}/master/master.xml") { |f| Nokogiri::XML(f) }
              object_node = master.xpath("/objects/object[identifier = 'id001']")
              object_node.remove
              object_node = master.xpath("/objects/object[identifier = 'id004']/pid")
              object_node.remove
              File.open("#{@ingestable_dir}/master/master.xml", 'w') { |f| master.write_xml_to f }
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            end
            it_behaves_like "a validated ingest"
          end
          context "object not in repository" do
            let(:results) { Hash[ "id001" => "PASS", "id002" => "FAIL", "id004" => "PASS" ] }
            before do
              TestModel.find("test:2").delete
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            end
            it_behaves_like "a validated ingest"
          end
          context "missing datastream content" do
            let(:results) { Hash[ "id001" => "FAIL", "id002" => "FAIL", "id004" => "FAIL" ] }
            let(:details) do
              Hash[
                "id001" => "marcXML datastream present and not empty...FAIL",
                "id002" => "marcXML datastream present and not empty...FAIL",
                "id004" => "marcXML datastream present and not empty...FAIL",
              ]
            end
            before do
              manifest = File.open(@manifest_file) { |f| YAML::load(f) }
              manifest[:metadata] = ["marcxml", "descmetadata"]
              File.open(@manifest_file, "w") { |f| YAML::dump(manifest, f)}
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            end
            it_behaves_like "a validated ingest"
            it_behaves_like "a validated ingest with repository objects"
          end
        end
      end      
      context "object has stored file" do
        before do
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/base_manifest_single.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/base_master_single_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
          @object = TestFileDatastreams.create(:pid => "test:5", :identifier => "id005")
          file = File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml")
          @object.contentdm.content_file = file
          @object.save!
          file.close          
        end
        after do
          @object.preservation_events.each { |pe| pe.delete }
          @object.reload
          @object.delete
        end
        context "stored file does not match" do
          let(:object_type) { TestFileDatastreams }
          let(:results) { Hash[ "id005" => "FAIL" ] }
          let(:details) { Hash[ "id005" => "contentdm datastream internal checksum...FAIL" ] }
          before do
            location_pattern = @object.contentdm.profile["dsLocation"]
            location_pattern.gsub!(":","%3A")
            location_pattern.gsub!("+","%2F")
            locations = locate_datastream_content_file(location_pattern)
            location = locations.first
            FileUtils.cp("#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xls", location)
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
          end
          it_behaves_like "a validated ingest"
          it_behaves_like "a validated ingest with repository objects"
        end
      end
      context "object is child to parent object" do
        let(:object_type) { TestChild }
        before do
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/child_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @objects = [
                      TestChild.create(:pid => "test:1", :identifier => "id001"),
                      TestChild.create(:pid => "test:2", :identifier => "id002")
                      ]
          @parent1 = TestParent.create(:pid => "test:3", :identifier => "id0")
          @parent2 = TestParent.create(:pid => "test:4", :identifier => "parent01")
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          parent_master = create_supporting_master([@parent1, @parent2])
          @parent_master_file = File.open("/tmp/foo.xml", 'w') { |f| parent_master.write_xml_to f } # need to have better way to place file
          update_manifest(@manifest_file, {:parent => {:master => "/tmp/foo.xml", :autoidlength => 3}})
          FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/child_master_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
        end
        after do
          @parent1.delete
          @parent2.delete
          @objects.each do |object|
            object.preservation_events.each { |pe| pe.delete }
            object.reload
            object.delete
          end          
        end
        context "correct parent-child relationship exists" do
          let(:results) { Hash[ "id001" => "PASS", "id002" => "PASS" ] }
          before do
            @objects[0].parent = @parent1
            @objects[0].save!
            @objects[1].parent = @parent2
            @objects[1].save!
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
          end
          it_behaves_like "a validated ingest"
          it_behaves_like "a validated ingest with repository objects"            
        end
        context "correct parent-child relationship does not exist" do
          let(:results) { Hash[ "id001" => "FAIL", "id002" => "FAIL" ] }
          let(:details) do
            Hash[
                 "id001" => "child relationship to identifier id0...FAIL",
                 "id002" => "child relationship to identifier parent01...FAIL"
            ]
          end
          before do
            @objects[0].parent = @parent2
            @objects[0].save!
            @objects[1].parent = @parent1
            @objects[1].save!
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
          end
          it_behaves_like "a validated ingest"
          it_behaves_like "a validated ingest with repository objects"                      
        end
      end
      context "object contains content" do
        let(:object_type) { TestContent }
        before do
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/checksum_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/checksum_master_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
          FileUtils.mkdir "#{@ingestable_dir}/checksum"
          @object = TestContent.create(:pid => "test:1", :identifier => "id001")
          file = File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/id001.tif")
          @object.content.content_file = file
          @object.save!
          file.close
        end
        after do
          @object.preservation_events.each { |pe| pe.delete }
          @object.reload
          @object.delete
        end
        context "any ingest with content" do
          before do
            FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/checksums.xml", "#{@ingestable_dir}/checksum/checksums.xml"            
          end
          context "internal checksum matches" do
            let(:results) { Hash[ "id001" => "PASS" ] }
            before do
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)            
            end
            it_behaves_like "a validated ingest with content"            
          end
          context "internal checksum does not match" do
            let(:results) { Hash[ "id001" => "FAIL" ] }
            before do
              location_pattern = @object.content.profile["dsLocation"]
              location_pattern.gsub!(":","%3A")
              location_pattern.gsub!("+","%2F")
              locations = locate_datastream_content_file(location_pattern)
              location = locations.first
              FileUtils.cp("#{FIXTURES_BATCH_INGEST}/miscellaneous/T001.tif", location)
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)            
            end
            it_behaves_like "a validated ingest with content"                        
          end
        end
        context "external checksum data exists" do
          context "external checksum matches" do
            let(:results) { Hash[ "id001" => "PASS" ] }
            before do
              FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/checksums.xml", "#{@ingestable_dir}/checksum/checksums.xml"
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)            
            end
            it_behaves_like "a validated ingest"
            it_behaves_like "a validated ingest with repository objects"            
          end
          context "external checksum does not match" do
            let(:results) { Hash[ "id001" => "FAIL" ] }
            let(:details) { Hash[ "id001" => "content datastream external checksum...FAIL" ] }
            before do
              FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/incorrect_checksums.xml", "#{@ingestable_dir}/checksum/checksums.xml"
              DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)            
            end
            it_behaves_like "a validated ingest"
            it_behaves_like "a validated ingest with repository objects"            
          end
        end        
      end
      context "target has associated collection" do
        let(:object_type) { Target }
        let(:target) { Target.create(:pid => "test:1", :identifier => "id001") }
        let(:collection) { Collection.create(:pid => "test:2", :identifier => "collection_1") }
        before do
          FileUtils.cp File.join(FIXTURES_BATCH_INGEST, 'manifests', 'target_manifest.yml'), File.join(@manifest_dir, 'manifest.yml')
          @manifest_file = File.join(@manifest_dir, 'manifest.yml')
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          FileUtils.mkdir_p(File.join(@ingestable_dir, 'master')) unless File.exists?(File.join(@ingestable_dir, 'master'))
          FileUtils.cp File.join(FIXTURES_BATCH_INGEST, 'master', 'target_master_with_pids.xml'), File.join(@ingestable_dir, 'master', 'master.xml')
          collection_master = create_supporting_master([collection])
          @collection_dir = Dir.mktmpdir("dul_hydra_test_collection")
          File.open(File.join(@collection_dir, 'manifest.xml'), 'w') { |f| collection_master.write_xml_to f }
          update_manifest(@manifest_file, {:collection => {:master => File.join(@collection_dir, 'manifest.xml')}})
        end
        after do
          collection.delete
          target.destroy
        end
        context "correct target-collection relationship exists" do
          let(:results) { Hash[ "id001" => "PASS" ] }
          before do
            target.collection = collection
            target.save!
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)            
          end
          it_behaves_like "a validated ingest"
          it_behaves_like "a validated ingest with repository objects"
        end
        context "correct target-collection relationship does not exist" do
          let(:results) { Hash[ "id001" => "FAIL" ] }
          let(:details) { Hash[ "id001" => "target relationship to collection collection_1...FAIL" ] }
          before do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)            
          end
          it_behaves_like "a validated ingest"
          it_behaves_like "a validated ingest with repository objects"
        end
      end
    end
  end
end
