require 'spec_helper'
require 'fileutils'
require "#{Rails.root}/spec/scripts/batch_ingest_spec_helper"
require 'support/shared_examples_for_batch_ingest'
require 'support/shared_examples_for_preservation_events'

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
        FileUtils.cp "spec/fixtures/batch_ingest/master/base_master.xml", "#{@ingestable_dir}/master/master.xml"
        FileUtils.cp "spec/fixtures/batch_ingest/qdc/id001.xml", "#{@ingestable_dir}/qdc"
        FileUtils.cp "spec/fixtures/batch_ingest/qdc/id002.xml", "#{@ingestable_dir}/qdc"
        FileUtils.cp "spec/fixtures/batch_ingest/qdc/id004.xml", "#{@ingestable_dir}/qdc"
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
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/manifest_with_files.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        it_behaves_like "an ingested batch with files"
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
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/child_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          update_manifest(@manifest_file, {:model => object_type.to_s})
          DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        end
        after do
          parents.values.each do |parent|
            parent.delete
          end
        end
        it_behaves_like "a child object"
      end
      context "Target" do
        context "target has associated collection" do
          let(:object_type) { Target }
          let!(:collection) { FactoryGirl.create(:collection, :identifier => "collection_1") }
          before do
            FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/target_manifest.yml", "#{@manifest_dir}/manifest.yml"
            @manifest_file = "#{@manifest_dir}/manifest.yml"
            update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
            DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
          end
          after do
            collection.delete
          end
          it_behaves_like "a target object"
        end
      end
    end
    describe "post-process ingest" do
      context "content structural metadata" do
        it "should add an appropriate contentMetadata datastream to the parent object" do
          pending("not creating contentMetadata at this time")
          DulHydra::Scripts::BatchIngest.post_process_ingest(@manifest_file)
          @item.reload
          @item.contentMetadata.content.should be_equivalent_to(@expected_xml)
        end
        it "should create an appropriate log file" do
          pending("not creating contentMetadata at this time")
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
              manifest[:metadata] = ["marcxml", "qdc"]
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
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/child_master_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
          @objects = [
                      TestChild.create(:pid => "test:1", :identifier => "id001"),
                      TestChild.create(:pid => "test:2", :identifier => "id002")
                      ]
          @parent1 = TestParent.create(:pid => "test:3", :identifier => "id0")
          @parent2 = TestParent.create(:pid => "test:4", :identifier => "parent01")
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
        before do
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/manifests/target_manifest.yml", "#{@manifest_dir}/manifest.yml"
          @manifest_file = "#{@manifest_dir}/manifest.yml"
          update_manifest(@manifest_file, {"basepath" => "#{@ingestable_dir}/"})
          FileUtils.cp "#{FIXTURES_BATCH_INGEST}/master/target_master_with_pids.xml", "#{@ingestable_dir}/master/master.xml"
          @target = Target.create(:pid => "test:1", :identifier => "id001")
          @collection = Collection.create(:pid => "test:2", :identifier => "collection_1")
        end
        after do
          @collection.delete
          @target.preservation_events.each { |pe| pe.delete }
          @target.reload
          @target.delete          
        end
        context "correct target-collection relationship exists" do
          let(:results) { Hash[ "id001" => "PASS" ] }
          before do
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
