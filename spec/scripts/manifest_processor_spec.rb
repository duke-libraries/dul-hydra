require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful manifest processing run" do
    let(:batch) { DulHydra::Batch::Models::Batch.all.last }
    let(:batch_objects) { batch.batch_objects }
    let(:batch_object) { batch_objects.first }
    let(:batch_object_datastreams) { batch_object.batch_object_datastreams }
    let(:batch_object_relationships) { batch_object.batch_object_relationships }
    after { batch.destroy }
    it "should create a new batch" do
      expect(batch.created_at).to be > 3.minutes.ago
      expect(batch.name).to eq(@manifest.batch_name)
      expect(batch.description).to eq(@manifest.batch_description)
    end
    it "should create a new batch object in the batch for each manifest object" do
      expect(batch_objects.size).to eq(@manifest.objects.size)
      expect(batch_object.identifier).to eq(@manifest.objects.first.key_identifier)
      expect(batch_object_datastreams.size).to eq(@manifest.objects.first.datastreams.size)
      batch_object_datastreams.each do |datastream|
        expect(datastream.operation).to eq(DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD)
        expect(datastream.payload_type).to eq(DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
        expect(datastream.batch_object).to eq(batch_object)
        expect(datastream.payload).to eq(@manifest.objects.first.datastream_filepath(datastream.name))
        if datastream.name.eql?(DulHydra::Datastreams::CONTENT)
          expect(datastream.checksum).to eq(@manifest.objects.first.checksum) if @manifest.objects.first.checksum?
          expect(datastream.checksum_type).to eq(@manifest.objects.first.checksum_type) if @manifest.objects.first.checksum_type?
        end
      end
      batch_object_relationships.each do |relationship|
        expect(relationship.operation).to eq(DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD)
        expect(relationship.object_type).to eq(DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID)
        case relationship.name
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY
          expect(relationship.object).to eq(apo.pid)
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT
          expect(relationship.object).to eq(parent_batch_object.pid)
        when DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ATTACHED_TO
          expect(relationship.object).to eq(attached_to_batch_object.pid)
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
    let(:apo) { AdminPolicy.create(title: "Test Policy") }
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
      after { parent_batch_object.destroy }
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
    context "attachment manifest" do
      let!(:attached_to_batch_object) { DulHydra::Batch::Models::BatchObject.create(:identifier => "id001", :pid=> "test:1234") }
      before do
        FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'manifests', 'attachment_manifest.yml'), manifest_file
        @manifest = DulHydra::Batch::Models::Manifest.new(manifest_file)
        @manifest.manifest_hash[DulHydra::Batch::Models::Manifest::BASEPATH] = test_dir
        @manifest.manifest_hash['admin_policy'] = apo.pid
        File.write(manifest_file, @manifest.manifest_hash.to_yaml)
        mp = DulHydra::Batch::Scripts::ManifestProcessor.new(:manifest => manifest_file, :log_dir => log_dir)
        mp.execute
      end
      after { attached_to_batch_object.destroy }
      it_behaves_like "a successful manifest processing run"      
    end
  end
  
end
