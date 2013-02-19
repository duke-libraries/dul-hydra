require 'spec_helper'
require "#{Rails.root}/spec/scripts/batch_ingest_spec_helper"

RSpec.configure do |c|
  c.include BatchIngestSpecHelper
end

module DulHydra::Scripts::Helpers

  describe BatchIngestHelper do
  
    module MockBatchIngest
      include DulHydra::Scripts::Helpers::BatchIngestHelper
    end
  
    describe "#split" do
      before do
        source_xml = <<-END
          <a>
            <b><c>idA</c><d>contentA</d></b>
            <b><c>idB</c><d>contentB</d></b>
            <b><c>idC</c><d>contentC</d></b>
          </a>
        END
        @source_doc = Nokogiri::XML(source_xml)
        result_a_xml = "<b><c>idA</c><d>contentA</d></b>"
        result_b_xml = "<b><c>idB</c><d>contentB</d></b>"
        result_c_xml = "<b><c>idC</c><d>contentC</d></b>"
        @result_a_doc = Nokogiri::XML(result_a_xml)
        @result_b_doc = Nokogiri::XML(result_b_xml)
        @result_c_doc = Nokogiri::XML(result_c_xml)
      end
      it "should create a hash of the elements" do
        expansion = MockBatchIngest.split(@source_doc, "/a/b", "c")
        expansion.should be_a_kind_of Hash
        expansion["idA"].should be_equivalent_to @result_a_doc
        expansion["idB"].should be_equivalent_to @result_b_doc
        expansion["idC"].should be_equivalent_to @result_c_doc
      end
    end
  
    describe "#load_yaml" do
      before do
        yaml_hash_string = File.open("spec/fixtures/batch_ingest/samples/sample_yaml_hash.txt") { |f| f.read }
        @expected_yaml = eval yaml_hash_string
      end
      it "should load the YAML file" do
        yaml = MockBatchIngest.load_yaml("spec/fixtures/batch_ingest/samples/sample.yml")
        yaml.should be_a_kind_of Hash
        yaml.should == @expected_yaml
      end
    end
    
    describe "#master_document" do
      context "master file does not exist" do
        it "should return a master file document with an empty objects root element" do
          master = MockBatchIngest.master_document("/path/to/nonexistent/master.xml")
          master.should be_equivalent_to Nokogiri::XML("<objects/>")
        end
      end
      context "master file does exist" do
        it "should return the existing master file document" do
          master = MockBatchIngest.master_document("spec/fixtures/batch_ingest/results/item_master.xml")
          master.should be_equivalent_to File.open("spec/fixtures/batch_ingest/results/item_master.xml") { |f| Nokogiri::XML(f) }
        end
      end
    end
    
    describe "#create_master_document" do
      it "should return a master file document with an empty objects root element" do
        master = MockBatchIngest.create_master_document()
        master.should be_equivalent_to Nokogiri::XML("<objects/>")
      end
    end
  
    describe "add_pid_to_master" do
      before do
        master_xml = <<-END
          <objects>
            <object model="info:fedora/objectModel">
              <identifier>object1Identifier</identifier>
            </object>
            <object model="info:fedora/objectModel">
              <identifier>duplicatedObjectIdentifier</identifier>
            </object>
            <object model="info:fedora/objectModel">
              <identifier>object2Identifier</identifier>
            </object>
            <object model="info:fedora/objectModel">
              <identifier>duplicatedObjectIdentifier</identifier>
            </object>
          </objects>
        END
        @master = Nokogiri::XML(master_xml)
        expected_master_xml = <<-END
          <objects>
            <object model="info:fedora/objectModel">
              <identifier>object1Identifier</identifier>
            </object>
            <object model="info:fedora/objectModel">
              <identifier>duplicatedObjectIdentifier</identifier>
            </object>
            <object model="info:fedora/objectModel">
              <identifier>object2Identifier</identifier>
              <pid>object2Pid</pid>
            </object>
            <object model="info:fedora/objectModel">
              <identifier>duplicatedObjectIdentifier</identifier>
            </object>
          </objects>      
        END
        @expected_master = Nokogiri::XML(expected_master_xml)
      end
      context "one object with specified identifier exists in master file" do
        it "should add a pid element to the the correct object element" do
          master = MockBatchIngest.add_pid_to_master(@master, "object2Identifier", "object2Pid")
          master.should be_equivalent_to @expected_master
        end      
      end
      context "no objects with specified identifier exists in master file" do
        it "should raise an appropriate error" do
          expect {
            MockBatchIngest.add_pid_to_master(@master, "nonExistentObjectIdentifier", "objectPid")
          }.to raise_error(/[Oo]bject nonExistentObjectIdentifier not found/)
        end
      end
      context "more than one object with specified identifier exists in master file" do
        it "should raise an appropriate error" do
          expect {
            MockBatchIngest.add_pid_to_master(@master, "duplicatedObjectIdentifier", "objectPid")
          }.to raise_error(/[Mm]ultiple objects found for duplicatedObjectIdentifier/)
        end
      end
    end
    
    describe "#add_manifest_object_to_master" do
      before do
        @object = HashWithIndifferentAccess.new
        @object["identifier"] = "addedObjectIdentifier"
        @object["model"] = "addedObjectModel"
        @manifest_model = "manifestModel"
      end
      context "first object to be added" do
        before do
          @master = Nokogiri::XML("<objects/>")
          @expected_master_xml = <<-END
            <objects>
              <object model="info:fedora/afmodel:addedObjectModel">
                <identifier>addedObjectIdentifier</identifier>
              </object>
            </objects>
          END
        end
        it "should add an object element to the objects node" do
          master = MockBatchIngest.add_manifest_object_to_master(@master, @object, @manifest_model)
          master.should be_equivalent_to Nokogiri::XML(@expected_master_xml)
        end
      end
      context "not first object to be added" do
        before do
          existing_master_xml = <<-END
            <objects>
              <object model="info:fedora/afmodel:existingObjectModel">
                <identifier>existingObjectIdentifier</identifier>
              </object>
            </objects>        
          END
          @master = Nokogiri::XML(existing_master_xml)
          @expected_master_xml = <<-END
            <objects>
              <object model="info:fedora/afmodel:existingObjectModel">
                <identifier>existingObjectIdentifier</identifier>
              </object>
              <object model="info:fedora/afmodel:addedObjectModel">
                <identifier>addedObjectIdentifier</identifier>
              </object>
            </objects>
          END
        end
        it "should add another object element to the objects node" do
          master = MockBatchIngest.add_manifest_object_to_master(@master, @object, @manifest_model)
          master.should be_equivalent_to Nokogiri::XML(@expected_master_xml)        
        end
      end
    end
    
    describe "#metadata_filepath" do
      before do
        @object = HashWithIndifferentAccess.new({"identifier" => "identifier", "qdcsource" => "marcxml"})
        @basepath = "/basepath/"
        @canonical_subpath = "marcxml/"
      end
      context "when the metadata file is in the canonical location" do
        context "when the metadata file is named in the object manifest" do
          before do
            @object["marcxml"] = "metadata.xml"
          end
          it "should return a file path for the named file in the canonical location" do
            filepath = MockBatchIngest.metadata_filepath(@object, @object[:qdcsource], @basepath)
            filepath.should == "#{@basepath}#{@canonical_subpath}metadata.xml"
          end
        end
        context "when the metadata file is not named in the object manifest" do
          it "should return a file path for an identifier-named file in the canonical location" do
            filepath = MockBatchIngest.metadata_filepath(@object, @object[:qdcsource], @basepath)
            filepath.should == "#{@basepath}#{@canonical_subpath}identifier.xml"
          end
        end
      end
      context "when the metadata file is not in the canonical location" do
        before do
          @object["marcxml"] = "/metadatapath/metadata.xml"
        end
        it "should return the specified file path" do
          filepath = MockBatchIngest.metadata_filepath(@object, @object[:qdcsource], @basepath)
          filepath.should == "/metadatapath/metadata.xml"
        end
      end
    end
      
    describe "#generate_qdc" do
      context "QDC source is CONTENTdm" do
        it "should create an appropriate Qualified Dublin Core document"
      end
      context "QDC source is digitization guide" do
        it "should create an appropriate Qualified Dublin Core document"
      end
      context "QDC source is MarcXML" do
        it "should create an appropriate Qualified Dublin Core document"
      end
    end
    
    describe "#stub_qdc" do
      before do
        @expected_qdc_xml = <<-END
          <dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          </dc>
        END
      end
      it "should create a shell Qualified Dublin Core document" do
        qdc = MockBatchIngest.stub_qdc()
        qdc.should be_equivalent_to Nokogiri::XML(@expected_qdc_xml)
      end
    end
    
    describe "#merge_identifiers" do
      before do
        @ingest_object_identifiers = ["idA", "idC"]
        @manifest_object_identifiers = ["idB", "idA"]
      end
      it "should merge the two lists of identifiers with no duplicates" do
        merged_identifiers = MockBatchIngest.merge_identifiers(@manifest_object_identifiers, @ingest_object_identifiers)
        merged_identifiers.should include("idA")
        merged_identifiers.should include("idB")
        merged_identifiers.should include("idC")
      end
    end
    
    describe "#key_identifier" do
      context "when the object has one identifier" do
        before do
          @object = HashWithIndifferentAccess.new
          @object["identifier"] = "identifier"        
        end
        it "should return that identifier" do
          key_identifier = MockBatchIngest.key_identifier(@object)
          key_identifier.should == "identifier"
        end
      end
      context "when the object has more than one identifier" do
        before do
          @object = HashWithIndifferentAccess.new
          @object["identifier"] = [ "identifier1", "identifier2" ]        
        end
        it "should return the first identifier" do
          key_identifier = MockBatchIngest.key_identifier(@object)
          key_identifier.should == "identifier1"
        end
      end
    end
    
    describe "#object_metadata" do
      before do
        @manifest = HashWithIndifferentAccess.new
        @object = HashWithIndifferentAccess.new
      end
      context "when neither manifest nor object have metadata" do
        it "should return an empty array" do
          metadata = MockBatchIngest.object_metadata(@object, @manifest[:metadata])
          metadata.should be_kind_of Array
          metadata.should be_empty
        end
      end
      context "when manifest has metadata but object does not" do
        before do
          @manifest[:metadata] = [ "m1", "m2" ]
        end
        it "should return an array containing the manifest metadata" do
          metadata = MockBatchIngest.object_metadata(@object, @manifest[:metadata])
          metadata.should be_kind_of Array
          metadata.should == [ "m1", "m2" ]
        end
      end
      context "when object has metadata but manifest does not" do
        before do
          @object[:metadata] = [ "m3", "m4" ]
        end
        it "should return an array containing the object metadata" do
          metadata = MockBatchIngest.object_metadata(@object, @manifest[:metadata])
          metadata.should be_kind_of Array
          metadata.should == [ "m3", "m4" ]
        end
      end
      context "when both manifiest and object have metadata" do
        before do
          @manifest[:metadata] = [ "m1", "m2" ]
          @object[:metadata] = [ "m3", "m4" ]
        end
        it "should return an array containing the object metadata" do
          metadata = MockBatchIngest.object_metadata(@object, @manifest[:metadata])
          metadata.should be_kind_of Array
          metadata.should == [ "m1", "m2", "m3", "m4" ]
        end
      end
    end

    describe "#get_parent" do
      before do
        @item = Item.create!
      end
      after do
        @item.delete
      end
      context "object is an item" do
        before do
          @collection = Collection.create!
          @item.collection = @collection
          @item.save!
        end
        after do
          @collection.delete
        end
        it "should return the appropriate collection" do
          MockBatchIngest.get_parent(@item).should eq(@collection)
        end
      end
    end
    
    describe "#get_child" do
      before do
        @item = Item.create!
      end
      after do
        @item.delete
      end
      context "object is a collection" do
        before do
          @collection = Collection.create!
          @item.collection = @collection
          @item.save!
        end
        after do
          @collection.delete
        end
        it "should return the appropriate item" do
          MockBatchIngest.get_children(@collection).should include(@item)
        end
      end
    end

    describe "#set_parent" do
      before do
        @item = Item.new
        @model = "Item"
        @collection = Collection.new(:pid => "test:collectionPid")
        @collection.identifier = "collectionIdentifier"
        @collection.save!
      end
      after do
        @collection.delete
      end
      context "item child object with parent identifier" do
        it "should set the collection attribute of the item to the collection parent" do
          object = MockBatchIngest.set_parent(@item, @model, :id, "collectionIdentifier")
          object.collection.should eq(@collection)
        end
      end
      context "item child object with parent pid" do
        it "should set the collection attribute of the item to the collection parent" do
          object = MockBatchIngest.set_parent(@item, @model, :pid, "test:collectionPid")
          object.collection.should eq(@collection)
        end
      end
    end
    
    describe "#parent_class" do
      it "should return the correct parent class for a given child model" do
        MockBatchIngest.parent_class("Item").should eq(Collection)
        MockBatchIngest.parent_class("Component").should eq(Item)      
      end
    end
    
    describe "#create_content_metadata_document" do
      before do
        @item = Item.create!
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
        @expected = create_expected_content_metadata_document
      end
      after do
        @component3.delete
        @component2.delete
        @component1.delete
        @item.reload
        @item.delete
      end
      it "should return the appropriate content metadata document" do
        content_metadata = MockBatchIngest.create_content_metadata_document(@item, 6, 3)
        content_metadata.should be_equivalent_to(@expected)
      end
    end
    
    describe "#validate_object_exists" do
      context "object exists" do
        before do
          @item = Item.create!        
        end
        after do
          @item.delete
        end
        context "object has expected model class" do
          it "should return true" do
            MockBatchIngest.validate_object_exists("Item", @item.pid).should be_true
          end
        end
        context "object does not have expected model class" do
          it "should return true" do
            MockBatchIngest.validate_object_exists("Component", @item.pid).should be_false
          end
        end
      end
      context "object does not exist" do
        before do
          item = Item.create!
          @pid = item.pid
          item.delete
        end
        it "should return false" do
          MockBatchIngest.validate_object_exists("Item", @pid).should be_false      
        end
      end
    end
  
    describe "#validate_populated_datastreams" do
      before do
        @item = Item.create!
        @item.title = "Test Title"
        @item.contentdm.content = "<root><foo/></root>"
        @item.save!
      end
      after do
        @item.delete
      end
      context "datastreams all exist" do
        context "datastreams are all populated" do
          it "should return true" do
            MockBatchIngest.validate_datastream_populated("descMetadata", @item).should be_true
            MockBatchIngest.validate_datastream_populated("contentdm", @item).should be_true
          end
        end
        context "datastreams are not all populated" do
          it "should return false" do
            MockBatchIngest.validate_datastream_populated("marcXML", @item).should be_false            
          end
        end
      end
      context "datastreams do not all exist" do
        it "should return false" do
          MockBatchIngest.validate_datastream_populated("content", @item).should be_false
        end
      end
    end
    
    describe "#verify_checksum(repository_object, checksum_doc)" do
      before do
        @component = Component.create!
        file = File.open("spec/fixtures/batch_ingest/samples/CCITT_2.TIF", "rb")
        @component.content.content_file = file
        @component.save!
        file.close
      end
      after do
        @component.delete
      end
      context "checksum matches" do
        before do
          @checksum_doc = File.open("spec/fixtures/batch_ingest/BASE/component/checksum/checksums.xml") { |f| Nokogiri::XML(f) }
        end
        it "should return true" do
          MockBatchIngest.verify_checksum(@component, "CCITT_2", @checksum_doc).should be_true
        end
      end
      context "checksum does not match" do
        before do
          @checksum_doc = File.open("spec/fixtures/batch_ingest/samples/incorrect_checksums.xml") { |f| Nokogiri::XML(f) }
        end
        it "should return true" do
          MockBatchIngest.verify_checksum(@component, "CCITT_2", @checksum_doc).should be_false
        end
      end

    end
    
  end

end
