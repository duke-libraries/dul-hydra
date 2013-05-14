require 'spec_helper'

module DulHydra::Scripts
  
  shared_examples "a successful processing run" do
    let(:batch) { Batch.all.last }
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
        expect(datastream.operation).to eq(BatchObjectDatastream::OPERATION_ADD)
        expect(datastream.payload_type).to eq(BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
        expect(datastream.batch_object).to eq(batch_object)
        case datastream.name
        when DulHydra::Datastreams::CONTENTDM
          expect(datastream.payload).to eq("placeholder/contentdm/metadata.xml")
          expect(datastream.checksum).to be_nil
        when DulHydra::Datastreams::DESC_METADATA
        when DulHydra::Datastreams::DIGITIZATION_GUIDE
        when DulHydra::Datastreams::DPC_METADATA
        when DulHydra::Datastreams::FMP_EXPORT
        when DulHydra::Datastreams::JHOVE
        when DulHydra::Datastreams::MARCXML
        when DulHydra::Datastreams::TRIPOD_METS
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
      let(:mp) { DulHydra::Scripts::ManifestProcessor.new(:manifest => manifest_file, :log_dir => log_dir) }
      before { mp.execute }
      context "successful processing run" do
        it_behaves_like "a successful processing run"
      end
    end
  end
  
end