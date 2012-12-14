require 'spec_helper'
require "#{Rails.root}/spec/scripts/ingest_prep_spec_helper"

RSpec.configure do |c|
  c.include IngestPrepSpecHelper
end

module DulHydra::Scripts::Helpers

describe BatchIngestHelper do

  module MockBatchIngest
    include DulHydra::Scripts::Helpers::BatchIngestHelper
  end

  describe "#load_yaml" do
    before do
      yaml_hash_string = File.open("spec/fixtures/batch_ingest/samples/sample_yaml_hash.txt") { |f| f.read }
      @expected_yaml = eval yaml_hash_string
    end
    it "should load the YAML file" do
      yaml = MockBatchIngest.load_yaml("spec/fixtures/batch_ingest/samples/sample.yaml")
      yaml.should be_a_kind_of Hash
      yaml.should == @expected_yaml
    end
  end
  
  describe "#create_master_document" do
    it "should return a master file document with an empty objects root element" do
      master = MockBatchIngest.create_master_document()
      master.should be_equivalent_to Nokogiri::XML("<objects/>")
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
            <object model="info:fedora/addedObjectModel">
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
            <object model="info:fedora/existingObjectModel">
              <identifier>existingObjectIdentifier</identifier>
            </object>
          </objects>        
        END
        @master = Nokogiri::XML(existing_master_xml)
        @expected_master_xml = <<-END
          <objects>
            <object model="info:fedora/existingObjectModel">
              <identifier>existingObjectIdentifier</identifier>
            </object>
            <object model="info:fedora/addedObjectModel">
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
      @object = HashWithIndifferentAccess.new({"identifier" => "identifier"})
      @basepath = "/basepath/"
      @type = "marcxml"
      @canonical_subpath = "marcxml/"
    end
    context "when the metadata file is in the canonical location" do
      context "when the metadata file is named in the object manifest" do
        before do
          @object["marcxml"] = "metadata.xml"
        end
        it "should return a file path for the named file in the canonical location" do
          filepath = MockBatchIngest.metadata_filepath(@type, @object, @basepath)
          filepath.should == "#{@basepath}#{@canonical_subpath}metadata.xml"
        end
      end
      context "when the metadata file is not named in the object manifest" do
        it "should return a file path for an identifier-named file in the canonical location" do
          filepath = MockBatchIngest.metadata_filepath(@type, @object, @basepath)
          filepath.should == "#{@basepath}#{@canonical_subpath}identifier.xml"
        end
      end
    end
    context "when the metadata file is not in the canonical location" do
      before do
        @object["marcxml"] = "/metadatapath/metadata.xml"
      end
      it "should return the specified file path" do
        filepath = MockBatchIngest.metadata_filepath(@type, @object, @basepath)
        filepath.should == "/metadatapath/metadata.xml"
      end
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
  
end

end
