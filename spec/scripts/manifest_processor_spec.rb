require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful processing run" do
    let(:batch) { DulHydra::Batch::Models::Batch.all.last }
    let(:batch_objects) { batch.batch_objects }
    let(:batch_object) { batch_objects.first }
    let(:batch_object_datastreams) { batch_object.batch_object_datastreams }
    let(:batch_object_relationships) { batch_object.batch_object_relationships }
    it "should create a new batch" do
      expect(batch.created_at).to be > 3.minutes.ago
      expect(batch.name).to eq("Test Batch")
      expect(batch.description).to eq("Description of test batch")
    end
    it "should create a new batch object in the batch for each manifest object" do
      expect(batch_objects.size).to eq(1)
      expect(batch_object.identifier).to eq("id001")
      expect(batch_object_datastreams.size).to eq(8)
      batch_object_datastreams.each do |datastream|
        expect(datastream.operation).to eq(DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD)
        expect(datastream.payload_type).to eq(DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
        expect(datastream.batch_object).to eq(batch_object)
        case datastream.name
        when DulHydra::Datastreams::CONTENT
          expect(datastream.payload).to eq("spec/fixtures/batch_ingest/miscellaneous/id001.tif")
          expect(datastream.checksum).to eq("120ad0814f207c45d968b05f7435034ecfee8ac1a0958cd984a070dad31f66f3")
          expect(datastream.checksum_type).to eq("SHA-256")
        when DulHydra::Datastreams::CONTENTDM
          expect(datastream.payload).to eq("placeholder/contentdm/metadata.xml")
          expect(datastream.checksum).to be_nil
        when DulHydra::Datastreams::DESC_METADATA
          expect(datastream.payload).to eq("placeholder/descMetadata/id001.xml")
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::DIGITIZATION_GUIDE
          expect(datastream.payload).to eq("placeholder/digitizationGuide/metadata.xls")
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::DPC_METADATA
          expect(datastream.payload).to eq("placeholder/dpcMetadata/id001.xml")
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::FMP_EXPORT
          expect(datastream.payload).to eq("placeholder/fmpExport/id001.xml")
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::MARCXML
          expect(datastream.payload).to eq("placeholder/marcXML/metadata.xml")
          expect(datastream.checksum).to be_nil
        when DulHydra::Datastreams::TRIPOD_METS
          expect(datastream.payload).to eq("placeholder/tripodMets/id001.xml")
          expect(datastream.checksum).to be_nil          
        end
      end
      expect(batch_object_relationships.size).to eq(2)
      batch_object_relationships.each do |relationship|
        expect(relationship.operation).to eq(DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD)
        expect(relationship.object_type).to eq(DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID)
        case relationship.name
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY
          expect(relationship.object).to eq("duke-apo:adminPolicy")
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT
          expect(relationship.object).to eq(parent_batch_object.pid)
        end
      end
    end
  end
  
  describe ManifestProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:log_dir) { test_dir }
    after { FileUtils.remove_dir test_dir }
    context "process" do
      let(:manifest_file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'manifests', 'manifest_with_files.yml') }
      let!(:parent_batch_object) { DulHydra::Batch::Models::BatchObject.create(:identifier => "id0", :pid=> "test:1234") }
      let(:mp) { DulHydra::Batch::Scripts::ManifestProcessor.new(:manifest => manifest_file, :log_dir => log_dir) }
      before { mp.execute }
      context "successful processing run" do
        it_behaves_like "a successful processing run"
      end
    end
  end
  
end