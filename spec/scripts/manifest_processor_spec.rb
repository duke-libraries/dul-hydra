require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful manifest processing run" do
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
          expect(datastream.payload).to eq(File.join(test_dir, 'contentdm', 'metadata.xml'))
          expect(datastream.checksum).to be_nil
        when DulHydra::Datastreams::DESC_METADATA
          expect(datastream.payload).to eq(File.join(test_dir, 'descMetadata', 'id001.xml'))
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::DIGITIZATION_GUIDE
          expect(datastream.payload).to eq(File.join(test_dir, 'digitizationGuide', 'metadata.xls'))
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::DPC_METADATA
          expect(datastream.payload).to eq(File.join(test_dir, 'dpcMetadata', 'id001.xml'))
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::FMP_EXPORT
          expect(datastream.payload).to eq(File.join(test_dir, 'fmpExport', 'id001.xml'))
          expect(datastream.checksum).to be_nil          
        when DulHydra::Datastreams::MARCXML
          expect(datastream.payload).to eq(File.join(test_dir, 'marcXML', 'metadata.xml'))
          expect(datastream.checksum).to be_nil
        when DulHydra::Datastreams::TRIPOD_METS
          expect(datastream.payload).to eq(File.join(test_dir, 'tripodMets', 'id001.xml'))
          expect(datastream.checksum).to be_nil          
        end
      end
      expect(batch_object_relationships.size).to eq(2)
      batch_object_relationships.each do |relationship|
        expect(relationship.operation).to eq(DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD)
        expect(relationship.object_type).to eq(DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID)
        case relationship.name
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY
          expect(relationship.object).to eq(apo.pid)
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT
          expect(relationship.object).to eq(parent_batch_object.pid)
        end
      end
    end
  end
  
  shared_examples "an invalid manifest to process" do
    let(:log) { File.read(File.join(log_dir, "manifest_processor.log"))}
    it "should not create a new batch" do
      expect(DulHydra::Batch::Models::Batch.all).to be_empty
    end
    it "should log the manifest errors" do
      expect(log).to include(I18n.t('batch.manifest.errors.basepath_error', :path => 'placeholder'))
      expect(log).to include(I18n.t('batch.manifest.errors.relationship_object_not_found', :relationship => 'admin_policy', :pid => 'duke-apo:adminPolicy'))
      expect(log).to include(I18n.t('batch.manifest.validation_failed'))
    end
  end
  
  describe ManifestProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:manifest_file) { File.join(test_dir, 'manifest.yml') }
    let(:log_dir) { test_dir }
    let(:apo) { AdminPolicy.create }
    after do
      FileUtils.remove_dir test_dir
      apo.destroy
    end
    context "process" do
      let!(:parent_batch_object) { DulHydra::Batch::Models::BatchObject.create(:identifier => "id0", :pid=> "test:1234") }
      before do
        FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'manifests', 'manifest_with_files.yml'), manifest_file
        @manifest = DulHydra::Batch::Models::Manifest.new(manifest_file)
      end
      context "successful processing run" do
        before do
          @manifest.manifest_hash[DulHydra::Batch::Models::Manifest::BASEPATH] = test_dir
          @manifest.manifest_hash['admin_policy'] = apo.pid
          File.write(manifest_file, @manifest.manifest_hash.to_yaml)
          mp = DulHydra::Batch::Scripts::ManifestProcessor.new(:manifest => manifest_file, :log_dir => log_dir)
          mp.execute
        end
        it_behaves_like "a successful manifest processing run"
      end
      context "invalid manifest" do
        before do
          mp = DulHydra::Batch::Scripts::ManifestProcessor.new(:manifest => manifest_file, :log_dir => log_dir)
          mp.execute
        end
        it_behaves_like "an invalid manifest to process"
      end
    end
  end
  
end