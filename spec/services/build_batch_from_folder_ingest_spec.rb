require 'spec_helper'
require 'support/ingest_folder_helper'

RSpec.describe BuildBatchFromFolderIngest, type: :service, batch: true, simple_ingest: true do

  let(:user) { FactoryGirl.create(:user) }
  let(:batch_name) { "Test Ingest Batch" }
  let(:batch_description) { "Testing ingest batch building" }
  let(:filesystem) { Filesystem.new }
  let(:batch_builder) { described_class.new(user, filesystem, content_modeler, metadata_provider, checksum_provider, batch_name, batch_description) }

  context 'simple ingest' do

    let(:content_modeler) { ModelSimpleIngestContent }
    let(:metadata_provider) { double("SimpleIngestMetadata") }
    let(:checksum_provider) { double("SimpleIngestChecksum") }

    before do
      filesystem.tree = filesystem_simple_ingest
      allow(metadata_provider).to receive(:metadata) { { } }
      allow(metadata_provider).to receive(:metadata).with(nil) { { title: 'Collection Title' } }
      allow(metadata_provider).to receive(:metadata).with('[movie.mp4]') { { title: 'Title 1' } }
      allow(metadata_provider).to receive(:metadata).with('[file01001.tif]') { { title: 'Title 2' } }
      allow(metadata_provider).to receive(:metadata).with('itemA') { { title: 'Title 3' } }
      allow(metadata_provider).to receive(:metadata).with('itemB') { { title: 'Title 4' } }
      allow(checksum_provider).to receive(:checksum).with('[movie.mp4]/movie.mp4') { '4f7bf7c679ab58da75c021279ae08b59e609801fe3ee8401d7cdb4d0ea3c4697' }
      allow(checksum_provider).to receive(:checksum).with('[file01001.tif]/file01001.tif') { '6cba6e3bcefc0454c1ec15ef44b0798e1de7d0d7a776ea341ecf16ea1ea2e162' }
      allow(checksum_provider).to receive(:checksum).with('itemA/file01.pdf') { 'e20e0a30eee4e29eea5e1ef6eed422cd33174810a433e688c503a4b805b9c6fa' }
      allow(checksum_provider).to receive(:checksum).with('itemA/track01.wav') { 'd72880438ba42224b9dd185e4e8c1b60e6ddf61d977d0b99aed72bb9f964657b' }
      allow(checksum_provider).to receive(:checksum).with('itemB/file02.pdf') { 'a2b872e2a3958a1ec7de3afcfd017d323c0a43dcebf0e607ab31acde4799aa8f' }
      allow(checksum_provider).to receive(:checksum).with('itemB/track02.wav') { 'dd60f671e6f31c75f11643e98384f71864ee654c6afb9d26cdc6a7c458741d47' }
    end

    it "should build an appropriate batch" do
      batch = batch_builder.call
    
      # Batch expectations
      expect(batch.id).to be_present
      expect(batch.name).to eq(batch_name)
      expect(batch.description).to eq(batch_description)
      expect(batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_READY)

      # Batch objects
      batch_objects = batch.batch_objects
      collections = batch_objects.where(model: 'Collection')
      items = batch_objects.where(model: 'Item')
      components = batch_objects.where(model: 'Component')

      # All batch object expectations
      batch_objects.each do |obj|
        expect(obj.type).to eq('DulHydra::Batch::Models::IngestBatchObject')
        admin_policy_relationships = obj.batch_object_relationships.where(
                                        name: DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY)
        expect(admin_policy_relationships.size).to eq(1)
        expect(admin_policy_relationships.first.object).to eq(collections.first.pid)
      end

      # Collection expectations
      expect(collections.count).to eq(1)
      expect(collections.first.pid).to be_present
      expect(collections.first.batch_object_attributes.where(name: 'title').first.value).to eq('Collection Title')

      # Item expectations
      expect(items.count).to eq(4)
      item_pids = []
      item_titles = []
      items.each do |obj|
        expect(obj.pid).to be_present
        item_pids << obj.pid
        parent_relationships = obj.batch_object_relationships.where(
                                  name: DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT)
        expect(parent_relationships.size).to eq(1)
        expect(parent_relationships.first.object).to eq(collections.first.pid)
        item_titles << obj.batch_object_attributes.where(name: 'title').first.value
      end
      expect(item_titles).to include('Title 1')
      expect(item_titles).to include('Title 2')
      expect(item_titles).to include('Title 3')
      expect(item_titles).to include('Title 4')

      # Component expectations
      expect(components.count).to eq(6)
      component_filepaths = []
      component_checksums = []
      components.each do |obj|
        # Parent relationship
        parent_relationships = obj.batch_object_relationships.where(
                                  name: DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT)
        expect(parent_relationships.size).to eq(1)
        expect(item_pids).to include(parent_relationships.first.object)
        # Content datastream
        content_datastreams = obj.batch_object_datastreams.where(
                                  name: Ddr::Datastreams::CONTENT)
        expect(content_datastreams.size).to eq(1)
        expect(content_datastreams.first.checksum_type).to eq(Ddr::Datastreams::CHECKSUM_TYPE_SHA256)
        component_filepaths << content_datastreams.first.payload
        component_checksums << content_datastreams.first.checksum
      end
      expect(component_filepaths).to include('/test/directory/[movie.mp4]/movie.mp4')
      expect(component_filepaths).to include('/test/directory/[file01001.tif]/file01001.tif')
      expect(component_filepaths).to include('/test/directory/itemA/file01.pdf')
      expect(component_filepaths).to include('/test/directory/itemA/track01.wav')
      expect(component_filepaths).to include('/test/directory/itemB/file02.pdf')
      expect(component_filepaths).to include('/test/directory/itemB/track02.wav')
      expect(component_checksums).to include('4f7bf7c679ab58da75c021279ae08b59e609801fe3ee8401d7cdb4d0ea3c4697')
      expect(component_checksums).to include('6cba6e3bcefc0454c1ec15ef44b0798e1de7d0d7a776ea341ecf16ea1ea2e162')
      expect(component_checksums).to include('e20e0a30eee4e29eea5e1ef6eed422cd33174810a433e688c503a4b805b9c6fa')
      expect(component_checksums).to include('d72880438ba42224b9dd185e4e8c1b60e6ddf61d977d0b99aed72bb9f964657b')
      expect(component_checksums).to include('a2b872e2a3958a1ec7de3afcfd017d323c0a43dcebf0e607ab31acde4799aa8f')
      expect(component_checksums).to include('dd60f671e6f31c75f11643e98384f71864ee654c6afb9d26cdc6a7c458741d47')
    end

  end

end