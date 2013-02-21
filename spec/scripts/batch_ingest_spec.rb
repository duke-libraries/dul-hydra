require 'spec_helper'
require 'fileutils'
require "#{Rails.root}/spec/scripts/batch_ingest_spec_helper"
require 'support/shared_examples_for_batch_ingest'

RSpec.configure do |c|
  c.include BatchIngestSpecHelper
end

module DulHydra::Scripts
  
  FIXTURES_BATCH_INGEST = "spec/fixtures/batch_ingest"

  describe BatchIngest do
    before do
      setup_test_dir
      FileUtils.mkdir "#{@ingestable_dir}/master"
      FileUtils.mkdir "#{@ingestable_dir}/qdc"
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
          File.size?("#{@ingestable_dir}/qdc/id001.xml").should_not be_nil
          File.size?("#{@ingestable_dir}/qdc/id002.xml").should_not be_nil
          File.size?("#{@ingestable_dir}/qdc/id004.xml").should_not be_nil
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
        #FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/base_manifest.yml", "#{@manifest_dir}/manifest.yml"
        #@manifest_file = "#{@manifest_dir}/manifest.yml"
        #update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})        
        FileUtils.cp "spec/fixtures/batch_ingest/master/base_master.xml", "#{@ingestable_dir}/master/master.xml"
        FileUtils.cp "spec/fixtures/batch_ingest/qdc/id001.xml", "#{@ingestable_dir}/qdc"
        FileUtils.cp "spec/fixtures/batch_ingest/qdc/id002.xml", "#{@ingestable_dir}/qdc"
        FileUtils.cp "spec/fixtures/batch_ingest/qdc/id004.xml", "#{@ingestable_dir}/qdc"
#        update_manifest(@manifest_file, {:model => object_type.to_s})
#        DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
      end
      after do
        object_type.find_each do |object|
          object.preservation_events.each { |pe| pe.delete }
          object.reload
          object.delete
        end
        admin_policy.delete
      end
      context "TestModel" do
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
      context "metadata files to be ingested" do
        let(:object_type) { TestMetadataFileDatastreams }
        let(:xls_file) { File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xls") { |f| f.read } }
        let(:xml_file) { File.open("#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml") { |f| f.read } }
        before do
          FileUtils.mkdir "#{@ingestable_dir}/contentdm"
          FileUtils.mkdir "#{@ingestable_dir}/digitizationguide"
          FileUtils.mkdir "#{@ingestable_dir}/dpcmetadata"
          FileUtils.mkdir "#{@ingestable_dir}/fmpexport"
          FileUtils.mkdir "#{@ingestable_dir}/jhove"
          FileUtils.mkdir "#{@ingestable_dir}/marcxml"
          FileUtils.mkdir "#{@ingestable_dir}/tripodmets"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/contentdm/"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xls", "#{@ingestable_dir}/digitizationguide/"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/dpcmetadata/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/fmpexport/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/jhove/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/marcxml/"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/miscellaneous/metadata.xml", "#{@ingestable_dir}/tripodmets/id001.xml"
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/manifest_with_metadata_files.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          update_manifest(@manifest_file, {:model => object_type.to_s})
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        it_behaves_like "an ingested batch with metadata files"
      end



      context "content to be ingested" do
        before do
          FileUtils.mkdir_p "#{@ingest_base}/component/master"
          FileUtils.mkdir_p "#{@ingest_base}/component/qdc"          
          FileUtils.mkdir_p "#{@ingest_base}/component/content"          
          FileUtils.cp "spec/fixtures/batch_ingest/results/component_master.xml", "#{@ingest_base}/component/master/master.xml"
          FileUtils.cp "spec/fixtures/batch_ingest/results/qdc/CCITT_2.xml", "#{@ingest_base}/component/qdc/"
          FileUtils.cp "spec/fixtures/batch_ingest/samples/CCITT_2.TIF", "#{@ingest_base}/component/content/"
          @pre_existing_component_pids = []
          Component.find_each { |c| @pre_existing_component_pids << c.pid }
          @manifest_file = "#{@ingest_base}/manifests/component_manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/component/"})
          @ingested_identifiers = [ [ "CCITT_2" ] ]
          @expected_content = File.open("spec/fixtures/batch_ingest/samples/CCITT_2.TIF", "rb")
        end
        after do
          @expected_content.close
          Component.find_each do |c|
            if !@pre_existing_component_pids.include?(c.pid)
              c.preservation_events.each do |pe|
                pe.delete
              end
              c.reload
              c.delete
            end
          end
        end
        it "should add a content datastream containing the content file" do
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
          components = []
          Component.find_each do |c|
            if !@pre_existing_component_pids.include?(c.pid)
              components << c
            end
          end
          components.each do |component|
            if component.identifier == [ "CCITT_2" ]
              component.content.label.should == "Content file for this object"
              content = component.datastreams["content"].content
              FileUtils.compare_stream(StringIO.new(content, "rb"), @expected_content)
            end
          end
        end
      end
      context "object has parent object" do
        context "child is part of parent" do
          context "parent identifier is determined algorithmically" do
            before do
              FileUtils.mkdir_p "#{@ingest_base}/component/master"
              FileUtils.mkdir_p "#{@ingest_base}/component/qdc"          
              FileUtils.mkdir_p "#{@ingest_base}/component/content"          
              FileUtils.cp "spec/fixtures/batch_ingest/results/component_master.xml", "#{@ingest_base}/component/master/master.xml"
              FileUtils.cp "spec/fixtures/batch_ingest/results/qdc/CCITT_2.xml", "#{@ingest_base}/component/qdc/"
              FileUtils.cp "spec/fixtures/batch_ingest/samples/CCITT_2.TIF", "#{@ingest_base}/component/content/"
              @pre_existing_component_pids = []
              Component.find_each { |c| @pre_existing_component_pids << c.pid }
              @manifest_file = "#{@ingest_base}/manifests/component_manifest.yml"
              update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/component/"})
              update_manifest(@manifest_file, {"autoparentidlength" => 5})
              @item = Item.new(:pid => "test:item1")
              @item.identifier = "CCITT"
              @item.save!
            end
            after do
              Component.find_each do |c|
                if !@pre_existing_component_pids.include?(c.pid)
                  c.preservation_events.each do |pe|
                    pe.delete
                  end
                  c.reload
                  c.delete
                end
              end
              @item.reload
              @item.delete
            end
            it "should establish an 'isPartOf' relationship between the child and parent" do
              DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
              components = []
              Component.find_each do |c|
                if !@pre_existing_component_pids.include?(c.pid)
                  components << c
                end
              end
              components.each do |component|
                component.container.should eq(@item)
                @item.parts.should include(component)
              end
            end
          end
        end
        context "child is member of parent" do
          context "parent identifier is specified is manifest" do
            before do
              FileUtils.mkdir_p "#{@ingest_base}/collection/master"
              FileUtils.mkdir_p "#{@ingest_base}/item/master"
              FileUtils.mkdir_p "#{@ingest_base}/item/qdc"          
              FileUtils.mkdir_p "#{@ingest_base}/item/tripodmets"
              FileUtils.cp "spec/fixtures/batch_ingest/results/item_master.xml", "#{@ingest_base}/item/master/master.xml"
              FileUtils.cp "spec/fixtures/batch_ingest/results/collection_master_with_pid.xml", "#{@ingest_base}/collection/master/master.xml"
              FileUtils.cp "spec/fixtures/batch_ingest/results/qdc/item_1.xml", "#{@ingest_base}/item/qdc"
              FileUtils.cp "spec/fixtures/batch_ingest/results/qdc/item_2.xml", "#{@ingest_base}/item/qdc"
              FileUtils.cp "spec/fixtures/batch_ingest/results/qdc/item_4.xml", "#{@ingest_base}/item/qdc"
              FileUtils.cp "spec/fixtures/batch_ingest/BASE/item/tripodmets/item1.xml", "#{@ingest_base}/item/tripodmets"
              FileUtils.cp "spec/fixtures/batch_ingest/BASE/item/tripodmets/item2.xml", "#{@ingest_base}/item/tripodmets"
              FileUtils.cp "spec/fixtures/batch_ingest/BASE/item/tripodmets/item4.xml", "#{@ingest_base}/item/tripodmets"
              @pre_existing_item_pids = []
              Item.find_each { |i| @pre_existing_item_pids << i.pid }
              @manifest_file = "#{@ingest_base}/manifests/item_manifest.yml"
              update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/item/"})
              @collection = Collection.new(:pid => "test:collection1")
              @collection.identifier = "collection_1"
              @collection.save!
            end
            after do
              Item.find_each do |i|
                if !@pre_existing_item_pids.include?(i.pid)
                  i.preservation_events.each do |pe|
                    pe.delete
                  end
                  i.reload
                  i.delete
                end
              end
              @collection.reload
              @collection.delete
            end
            it "should establish an 'isMemberOf' relationship between the child and parent" do
              DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
              items = []
              Item.find_each do |i|
                if !@pre_existing_item_pids.include?(i.pid)
                  items << i
                end
              end
              items.each do |item|
                item.collection.should eq(@collection)
                @collection.items.should include(item)
              end
            end
          end
        end
      end
      context "target has associated collection" do
        before do
          FileUtils.mkdir_p "#{@ingest_base}/collection/master"
          FileUtils.mkdir_p "#{@ingest_base}/target/log"          
          FileUtils.mkdir_p "#{@ingest_base}/target/master"
          FileUtils.mkdir_p "#{@ingest_base}/target/qdc"          
          FileUtils.cp "spec/fixtures/batch_ingest/results/target_master.xml", "#{@ingest_base}/target/master/master.xml"
          FileUtils.cp "spec/fixtures/batch_ingest/results/collection_master_with_pid.xml", "#{@ingest_base}/collection/master/master.xml"
          FileUtils.cp "spec/fixtures/batch_ingest/results/qdc/T001.xml", "#{@ingest_base}/target/qdc"
          @manifest_file = "#{@ingest_base}/manifests/target_manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/target/"})
          @pre_existing_target_pids = []
          Target.find_each { |t| @pre_existing_target_pids << t.pid }
          @collection = Collection.new(:pid => "test:collection1")
          @collection.identifier = "collection_1"
          @collection.save!
        end
        after do
          Target.find_each do |t|
            if !@pre_existing_target_pids.include?(t.pid)
              t.preservation_events.each do |pe|
                pe.delete
              end
              t.reload
              t.delete
            end
          end
          @collection.reload
          @collection.delete          
        end
        context "collection identifier is specified in manifest" do
          it "should extablish an 'isExternalTargetOf' relationship between the target and the collection" do
            DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
            targets = []
            Target.find_each do |t|
              if !@pre_existing_target_pids.include?(t.pid)
                targets << t
              end
            end
            targets.each do |target|
              target.collection.should eq(@collection)
              @collection.targets.should include(target)
            end
          end
        end
      end
    end
    describe "post-process ingest" do
      context "content structural metadata" do
        before do
          FileUtils.mkdir_p "#{@ingest_base}/item/contentmetadata"          
          @item = Item.new
          @item.identifier = "test01"
          @item.save!
          @component1 = Component.new
          @component1.identifier = "test010020010"
          @component1.container = @item
          @component1.save!
          @component2 = Component.new
          @component2.identifier = "test010030010"
          @component2.container = @item
          @component2.save!
          @component3 = Component.new
          @component3.identifier = "test010010010"
          @component3.container = @item
          @component3.save!
          @manifest_file = "#{@ingest_base}/manifests/simple_item_manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/item/"})
          @expected_doc = create_expected_content_metadata_document
          @expected_xml = @expected_doc.to_xml
        end
        after do
          @component3.delete
          @component2.delete
          @component1.delete
          @item.delete
        end
        it "should add an appropriate contentMetadata datastream to the parent object" do
          DulHydra::Scripts::BatchIngest.post_process_ingest(@manifest_file)
          @item.reload
          @item.contentMetadata.content.should be_equivalent_to(@expected_xml)
        end
        it "should create an appropriate log file" do
          DulHydra::Scripts::BatchIngest.post_process_ingest(@manifest_file)
          result = File.open("#{@ingest_base}/item/log/ingest_postprocess.log") { |f| f.read }
          result.should match("DulHydra version #{DulHydra::VERSION}")
          result.should match("Manifest: #{@ingest_base}/manifests/simple_item_manifest.yml")
          result.should match("Added contentmetadata datastream for test01 to #{Item.find_by_identifier("test01").first.pid}")
          result.should match("Post-processed 1 object\\(s\\)")
        end        
      end
    end
    describe "validate ingest" do
      context "any batch ingest" do
        before do
          FileUtils.mkdir_p "#{@ingest_base}/collection/master"          
          FileUtils.mkdir_p "#{@ingest_base}/collection/qdc"          
          @manifest_file = "#{@ingest_base}/manifests/collection_manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/collection/"})
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          @adminPolicy = AdminPolicy.new(pid: 'duke-apo:adminPolicy', label: 'Public Read')
          @adminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS,
                                              DulHydra::Permissions::READER_GROUP_ACCESS,
                                              DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                              DulHydra::Permissions::ADMIN_GROUP_ACCESS]
          @adminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
          @adminPolicy.save!
          @pre_existing_collection_pids = []
          Collection.find_each { |c| @pre_existing_collection_pids << c.pid }
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)  
        end
        after do
          @adminPolicy.delete
          Collection.find_each do |c|
            if !@pre_existing_collection_pids.include?(c.pid)
              c.preservation_events.each do |pe|
                pe.delete
              end
              c.reload
              c.delete
            end
          end
        end
        context "ingest is valid" do
          it "should declare the ingest to be valid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_true
          end
          it "should create a success validation preservation event in the repository" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            collections = []
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                collections << c
              end
            end
            collections.each do |collection|
              events = collection.preservation_events
              events.should_not be_empty
              validation_events = []
              events.each do |event|
                if event.event_type == PreservationEvent::VALIDATION
                  validation_events << event
                end
              end
              validation_events.should_not be_empty
              validation_events.size.should == 1
              event = validation_events.first
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
              event.event_outcome.should == PreservationEvent::SUCCESS
              event.linking_object_id_type.should == PreservationEvent::OBJECT
              event.linking_object_id_value.should == collection.internal_uri
              event.event_detail.should include("Identifier(s): collection_1")
              event.event_detail.should include("PASS")
              event.event_detail.should_not include("FAIL")
              event.event_detail.should include ("VALIDATES")
              event.for_object.should == collection
            end
          end
          it "should create an appropriate log file" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            result = File.open("#{@ingest_base}/collection/log/ingest_validation.log") { |f| f.read }
            result.should match("DulHydra version #{DulHydra::VERSION}")
            result.should match("Manifest: #{@ingest_base}/manifests/collection_manifest.yml")
            result.should match("Validated Collection collection_1 in #{Collection.find_by_identifier("collection_1").first.pid}...PASS")
            result.should match("Validated 1 object\\(s\\)")
          end
        end
        context "manifest object is missing from master file" do
          before do
            master = File.open("#{@ingest_base}/collection/master/master.xml") { |f| Nokogiri::XML(f) }
            object_node = master.xpath("/objects/object").first
            object_node.remove
            File.open("#{@ingest_base}/collection/master/master.xml", 'w') { |f| master.write_xml_to f }
          end
          it "should declare the ingest to be invalid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_false            
          end
        end
        context "manifest object is missing pid in master file" do
          before do
            master = File.open("#{@ingest_base}/collection/master/master.xml") { |f| Nokogiri::XML(f) }
            object_node = master.xpath("/objects/object").first
            pid_node = object_node.xpath("pid").first
            pid_node.remove
            File.open("#{@ingest_base}/collection/master/master.xml", 'w') { |f| master.write_xml_to f }
          end
          it "should declare the ingest to be invalid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_false            
          end
        end
        context "object does not exist in the repository" do
          before do
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                c.preservation_events.each do |pe|
                  pe.delete
                end
                c.reload
                c.delete
              end
            end
          end
          it "should declare the ingest to be invalid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_false
          end
        end
        context "missing content in datastream" do
          before do
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                c.marcXML.delete
                c.save!
              end
            end
          end
          it "should declare the ingest to be invalid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_false
          end
          it "should create a failure validation preservation event in the repository" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            collections = []
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                collections << c
              end
            end
            collections.each do |collection|
              events = collection.preservation_events
              events.should_not be_empty
              validation_events = []
              events.each do |event|
                if event.event_type == PreservationEvent::VALIDATION
                  validation_events << event
                end
              end
              validation_events.should_not be_empty
              validation_events.size.should == 1
              event = validation_events.first
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
              event.event_outcome.should == PreservationEvent::FAILURE
              event.linking_object_id_value.should == collection.internal_uri
              event.event_detail.should include("marcXML datastream present and not empty...FAIL")
              event.event_detail.should include ("DOES NOT VALIDATE")
              event.for_object.should == collection
            end
          end
        end
        context "stored file does not match" do
          before do
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                location_pattern = c.digitizationGuide.profile["dsLocation"]
                location_pattern.gsub!(":","%3A")
                location_pattern.gsub!("+","%2F")
                locations = locate_datastream_content_file(location_pattern)
                location = locations.first
                FileUtils.cp("spec/fixtures/batch_ingest/BASE/collection/fmpexport/dpc_structural_metadata_vica.xls", location)
              end
            end            
          end
          it "should declare the ingest to be invalid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_false
          end
          it "should create a failure validation preservation event in the repository" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            collections = []
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                collections << c
              end
            end
            collections.each do |collection|
              events = collection.preservation_events
              events.should_not be_empty
              validation_events = []
              events.each do |event|
                if event.event_type == PreservationEvent::VALIDATION
                  validation_events << event
                end
              end
              validation_events.should_not be_empty
              validation_events.size.should == 1
              event = validation_events.first
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
              event.event_outcome.should == PreservationEvent::FAILURE
              event.linking_object_id_value.should == collection.internal_uri
              event.event_detail.should include("digitizationGuide datastream internal checksum...FAIL")
              event.event_detail.should include ("DOES NOT VALIDATE")
              event.for_object.should == collection
            end
          end
        end
      end
      context "object is child to parent object" do
        before do
          @adminPolicy = AdminPolicy.new(pid: 'duke-apo:adminPolicy', label: 'Public Read')
          @adminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS,
                                              DulHydra::Permissions::READER_GROUP_ACCESS,
                                              DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                              DulHydra::Permissions::ADMIN_GROUP_ACCESS]
          @adminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
          @adminPolicy.save!          
        end
        after do
          @adminPolicy.delete
        end
        context "parent ID is explicitly specified in manifest" do
          before do
            FileUtils.mkdir_p "#{@ingest_base}/collection/master"          
            FileUtils.mkdir_p "#{@ingest_base}/collection/qdc"          
            collection_manifest_file = "#{@ingest_base}/manifests/collection_manifest.yml"
            update_manifest(collection_manifest_file, {"basepath" => "#{@ingest_base}/collection/"})
            DulHydra::Scripts::BatchIngest.prep_for_ingest(collection_manifest_file)
            @pre_existing_collection_pids = []
            Collection.find_each { |c| @pre_existing_collection_pids << c.pid }
            DulHydra::Scripts::BatchIngest.ingest(collection_manifest_file)
            FileUtils.mkdir_p "#{@ingest_base}/item/master"          
            FileUtils.mkdir_p "#{@ingest_base}/item/qdc"          
            @item_manifest_file = "#{@ingest_base}/manifests/item_manifest.yml"
            update_manifest(@item_manifest_file, {"basepath" => "#{@ingest_base}/item/"})
            DulHydra::Scripts::BatchIngest.prep_for_ingest(@item_manifest_file)
            @pre_existing_item_pids = []
            Item.find_each { |i| @pre_existing_item_pids << i.pid }
            DulHydra::Scripts::BatchIngest.ingest(@item_manifest_file)
          end
          after do
            Item.find_each do |i|
              if !@pre_existing_item_pids.include?(i.pid)
                i.preservation_events.each do |pe|
                  pe.delete
                end
                i.reload
                i.delete
              end
            end
            Collection.find_each do |c|
              if !@pre_existing_collection_pids.include?(c.pid)
                c.preservation_events.each do |pe|
                  pe.delete
                end
                c.reload
                c.delete
              end
            end
          end
          context "correct parent-child relationship exists" do
            it "should declare the ingest to be valid" do
              DulHydra::Scripts::BatchIngest.validate_ingest(@item_manifest_file).should be_true
            end
          end
          context "correct parent-child relationship does not exist" do
            before do
              Item.find_each do |i|
                if !@pre_existing_item_pids.include?(i.pid)
                  i.collection = nil
                  i.save!
                end
              end
            end
            it "should declare the ingest to be invalid" do
              DulHydra::Scripts::BatchIngest.validate_ingest(@item_manifest_file).should be_false
            end
            it "should create a failure validation preservation event in the repository" do
              DulHydra::Scripts::BatchIngest.validate_ingest(@item_manifest_file)
              items = []
              Item.find_each do |i|
                if !@pre_existing_item_pids.include?(i.pid)
                  items << i
                end
              end
              items.each do |item|
                events = item.preservation_events
                events.should_not be_empty
                validation_events = []
                events.each do |event|
                  if event.event_type == PreservationEvent::VALIDATION
                    validation_events << event
                  end
                end
                validation_events.should_not be_empty
                validation_events.size.should == 1
                event = validation_events.first
                DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
                DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
                event.event_outcome.should == PreservationEvent::FAILURE
                event.linking_object_id_value.should == item.internal_uri
                case item.identifier
                when [ "item_1" ]
                  event.event_detail.should include("Identifier(s): item_1")
                when [ "item_2", "item_3" ]
                  event.event_detail.should include("Identifier(s): item_2,item_3")
                  event.event_detail.should_not include("Identifier(s): item_1")
                when [ "item_4" ]
                  event.event_detail.should include("Identifier(s): item_4")
                  event.event_detail.should_not include("Identifier(s): item_1")
                  event.event_detail.should_not include("Identifier(s): item_2,item_3")
                end
                event.event_detail.should include("child relationship to identifier collection_1...FAIL")
                event.event_detail.should include ("DOES NOT VALIDATE")
                event.for_object.should == item
              end
            end
          end
        end
        context "parent ID can be determined algorithmically from child ID" do
          before do
            @item = Item.new(:pid => "test:item1")
            @item.identifier = "CCITT"
            @item.save!
            FileUtils.mkdir_p "#{@ingest_base}/component/master"          
            FileUtils.mkdir_p "#{@ingest_base}/component/qdc"          
            @component_manifest_file = "#{@ingest_base}/manifests/component_manifest.yml"
            update_manifest(@component_manifest_file, {"basepath" => "#{@ingest_base}/component/"})
            update_manifest(@component_manifest_file, {"autoparentidlength" => 5})
            DulHydra::Scripts::BatchIngest.prep_for_ingest(@component_manifest_file)
            @pre_existing_component_pids = []
            Component.find_each { |c| @pre_existing_component_pids << c.pid }
            DulHydra::Scripts::BatchIngest.ingest(@component_manifest_file)
          end
          after do
            Component.find_each do |c|
              if !@pre_existing_component_pids.include?(c.pid)
                c.preservation_events.each do |pe|
                  pe.delete
                end
                c.reload
                c.delete
              end
            end
            @item.delete
          end
          context "correct parent-child relationship exists" do
            it "should declare the ingest to be valid" do
              DulHydra::Scripts::BatchIngest.validate_ingest(@component_manifest_file).should be_true
            end
          end
          context "correct parent-child relationship does not exist" do
            before do
              Component.find_each do |c|
                if !@pre_existing_component_pids.include?(c.pid)
                  c.container = nil
                  c.save!
                end
              end
            end
            it "should declare the ingest to be invalid" do
              DulHydra::Scripts::BatchIngest.validate_ingest(@component_manifest_file).should be_false
            end
            it "should create a failure validation preservation event in the repository" do
              DulHydra::Scripts::BatchIngest.validate_ingest(@component_manifest_file)
              components = []
              Component.find_each do |c|
                if !@pre_existing_component_pids.include?(c.pid)
                  components << c
                end
              end
              components.each do |component|
                events = component.preservation_events
                events.should_not be_empty
                validation_events = []
                events.each do |event|
                  if event.event_type == PreservationEvent::VALIDATION
                    validation_events << event
                  end
                end
                validation_events.should_not be_empty
                validation_events.size.should == 1
                event = validation_events.first
                DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
                DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
                event.event_outcome.should == PreservationEvent::FAILURE
                event.linking_object_id_value.should == component.internal_uri
                event.event_detail.should include ("child relationship to identifier CCITT...FAIL")
                event.event_detail.should include ("DOES NOT VALIDATE")
                event.for_object.should == component
              end
            end
          end          
        end
      end
      context "target has associated collection" do
        context "correct target-collection relationship exists" do
          it "should declare the ingest to be valid"
        end
        context "correct target-collection relationship does not exist" do
          it "should declare the ingest to be invalid"
          it "should create a failure validation preservation event in the repository"
        end
      end
      context "external checksum data exists" do
        before do
          FileUtils.mkdir_p "#{@ingest_base}/component/master"
          FileUtils.mkdir_p "#{@ingest_base}/component/qdc"          
          @manifest_file = "#{@ingest_base}/manifests/simple_component_manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/component/"})
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          @pre_existing_component_pids = []
          Component.find_each { |c| @pre_existing_component_pids << c.pid }
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)  
        end
        after do
          Component.find_each do |c|
            if !@pre_existing_component_pids.include?(c.pid)
              c.preservation_events.each do |pe|
                pe.delete
              end
              c.reload
              c.delete
            end
          end
        end
        context "checksum matches" do
          it "should declare the ingest to be valid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_true
          end
        end
        context "checksum does not match" do
          before do
            FileUtils.cp "spec/fixtures/batch_ingest/samples/incorrect_checksums_component_manifest.yml", "#{@ingest_base}/manifests"
            FileUtils.cp "spec/fixtures/batch_ingest/samples/incorrect_checksums.xml", "#{@ingest_base}/component/checksum"
            @manifest_file = "#{@ingest_base}/manifests/incorrect_checksums_component_manifest.yml"
            update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/component/"})
          end
          it "should declare the ingest to be invalid" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file).should be_false
          end
          it "should create a failure validation preservation event in the repository" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            components = []
            Component.find_each do |c|
              if !@pre_existing_component_pids.include?(c.pid)
                components << c
              end
            end
            components.each do |component|
              events = component.preservation_events
              events.should_not be_empty
              validation_events = []
              events.each do |event|
                if event.event_type == PreservationEvent::VALIDATION
                  validation_events << event
                end
              end
              validation_events.should_not be_empty
              validation_events.size.should == 1
              event = validation_events.first
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
              event.event_outcome.should == PreservationEvent::FAILURE
              event.linking_object_id_value.should == component.internal_uri
              event.event_detail.should include ("content datastream external checksum...FAIL")
              event.event_detail.should include ("DOES NOT VALIDATE")
              event.for_object.should == component
            end
          end
        end
      end
      context "object contains content" do
        before do
          FileUtils.mkdir_p "#{@ingest_base}/component/master"
          FileUtils.mkdir_p "#{@ingest_base}/component/qdc"          
          @manifest_file = "#{@ingest_base}/manifests/simple_component_manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingest_base}/component/"})
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          @pre_existing_component_pids = []
          Component.find_each { |c| @pre_existing_component_pids << c.pid }
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)  
        end
        after do
          Component.find_each do |c|
            if !@pre_existing_component_pids.include?(c.pid)
              c.preservation_events.each do |pe|
                pe.delete
              end
              c.reload
              c.delete
            end
          end
        end
        context "internal checksum validates for content datastream" do
          it "should create a success fixity check event in the repository" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            components = []
            Component.find_each do |c|
              if !@pre_existing_component_pids.include?(c.pid)
                components << c
              end
            end
            components.each do |component|
              events = component.preservation_events
              events.should_not be_empty
              fixity_check_events = []
              events.each do |event|
                if event.event_type == PreservationEvent::FIXITY_CHECK
                  fixity_check_events << event
                end
              end
              fixity_check_events.should_not be_empty
              fixity_check_events.size.should == 1
              event = fixity_check_events.first
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
              event.event_outcome.should == PreservationEvent::SUCCESS
              event.linking_object_id_type.should == PreservationEvent::DATASTREAM
              event.linking_object_id_value.should == component.ds_internal_uri("content")
              event.event_detail.should include("Internal validation of checksum")
              event.for_object.should == component
            end
          end
        end
        context "internal checksum does not validate for content datastream" do
          before do
            Component.find_each do |c|
              if !@pre_existing_component_pids.include?(c.pid)
                location_pattern = c.content.profile["dsLocation"]
                location_pattern.gsub!(":","%3A")
                location_pattern.gsub!("+","%2F")
                locations = locate_datastream_content_file(location_pattern)
                location = locations.first
                FileUtils.cp("spec/fixtures/library-devil.tiff", location)
              end
            end
          end
          it "should create a failure fixity check event in the repository" do
            DulHydra::Scripts::BatchIngest.validate_ingest(@manifest_file)
            components = []
            Component.find_each do |c|
              if !@pre_existing_component_pids.include?(c.pid)
                components << c
              end
            end
            components.each do |component|
              events = component.preservation_events
              events.should_not be_empty
              fixity_check_events = []
              events.each do |event|
                if event.event_type == PreservationEvent::FIXITY_CHECK
                  fixity_check_events << event
                end
              end
              fixity_check_events.should_not be_empty
              fixity_check_events.size.should == 1
              event = fixity_check_events.first
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
              DateTime.strptime(event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
              event.event_outcome.should == PreservationEvent::FAILURE
              event.linking_object_id_type.should == PreservationEvent::DATASTREAM
              event.linking_object_id_value.should == component.ds_internal_uri("content")
              event.event_detail.should include("Internal validation of checksum")
              event.for_object.should == component
            end            
          end
        end        
      end
    end  
  end
end
