require 'spec_helper'
require 'support/ingest_folder_helper'

RSpec.shared_examples "a successfully built nested folder ingest batch" do
  it "should build an appropriate batch" do
    # Batch expectations
    expect(batch.id).to be_present
    expect(batch.name).to eq(batch_name)
    expect(batch.description).to eq(batch_description)
    expect(batch.status).to eq(Ddr::Batch::Batch::STATUS_READY)

    # All batch object expectations
    batch_objects.each do |obj|
      expect(obj.type).to eq('Ddr::Batch::IngestBatchObject')
      admin_policy_relationships = obj.batch_object_relationships.where(
          name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY)
      expect(admin_policy_relationships.size).to eq(1)
      expect(admin_policy_relationships.first.object).to eq(coll_id)
    end

    # Collection expectations
    expect(collections.count).to eq(coll_count)
    if coll_count == 1
      expect(collections.first.id).to be_present
      expect(collections.first.batch_object_attributes.where(name: 'title').first.value).to eq(collection_title)
      expect(collections.first.batch_object_attributes.where(name: 'admin_set').first.value).to eq(admin_set)
      expect(collections.first.batch_object_roles.size).to eq(1)
      expect(collections.first.batch_object_roles[0].agent).to eq(user.user_key)
      expect(collections.first.batch_object_roles[0].role_type).to eq(Ddr::Auth::Roles::RoleTypes::CURATOR.title)
      expect(collections.first.batch_object_roles[0].role_scope).to eq(Ddr::Auth::Roles::POLICY_SCOPE)
    end

    # Item expectations
    expect(items.count).to eq(6)
    item_pids = []
    item_nested_paths = []
    items.each do |obj|
      expect(obj.id).to be_present
      item_pids << obj.pid
      item_nested_paths << obj.batch_object_attributes.where(name: 'nested_path').first.value
      parent_relationships = obj.batch_object_relationships.where(
          name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT)
      expect(parent_relationships.size).to eq(1)
      expect(parent_relationships.first.object).to eq(coll_id)
    end
    expect(item_nested_paths).to match_array(expected_nested_paths)

    # Component expectations
    expect(components.count).to eq(6)
    component_filepaths = []
    component_checksums = []
    components.each do |obj|
      # Parent relationship
      parent_relationships = obj.batch_object_relationships.where(
          name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT)
      expect(parent_relationships.size).to eq(1)
      expect(item_pids.map(&:to_s)).to include(parent_relationships.first.object)
      # Content datastream
      content_datastreams = obj.batch_object_datastreams.where(
          name: Ddr::Datastreams::CONTENT)
      expect(content_datastreams.size).to eq(1)
      expect(content_datastreams.first.checksum_type).to eq(Ddr::Datastreams::CHECKSUM_TYPE_SHA1)
      component_filepaths << content_datastreams.first.payload
      component_checksums << content_datastreams.first.checksum
    end
    expect(component_filepaths).to include('/test/directory/movie.mp4')
    expect(component_filepaths).to include('/test/directory/file01001.tif')
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

RSpec.describe BuildBatchFromNestedFolderIngest, type: :service, batch: true, ingest: true do

  let(:user) { FactoryGirl.create(:user) }
  let(:batch_name) { "Test Ingest Batch" }
  let(:batch_description) { "Testing ingest batch building" }
  let(:filesystem) { Filesystem.new }

  context 'nested ingest' do

    let(:content_modeler) { ModelNestedFolderIngestContent }
    let(:checksum_provider) { double("IngestChecksum") }
    let(:admin_set) { "abc" }
    let(:collection_title) { "My Collection" }

    let(:expected_nested_paths) { [ 'directory/movie.mp4', 'directory/file01001.tif', 'directory/itemA/file01.pdf',
                                    'directory/itemA/track01.wav', 'directory/itemB/file02.pdf',
                                    'directory/itemB/track02.wav' ] }

    let(:batch_objects) { batch.batch_objects }
    let(:collections) { batch_objects.where(model: 'Collection') }
    let(:items) { batch_objects.where(model: 'Item') }
    let(:components) { batch_objects.where(model: 'Component') }

    before do
      filesystem.tree = sample_filesystem
      allow(checksum_provider).to receive(:checksum).with('/test/directory/movie.mp4') { '4f7bf7c679ab58da75c021279ae08b59e609801fe3ee8401d7cdb4d0ea3c4697' }
      allow(checksum_provider).to receive(:checksum).with('/test/directory/file01001.tif') { '6cba6e3bcefc0454c1ec15ef44b0798e1de7d0d7a776ea341ecf16ea1ea2e162' }
      allow(checksum_provider).to receive(:checksum).with('/test/directory/itemA/file01.pdf') { 'e20e0a30eee4e29eea5e1ef6eed422cd33174810a433e688c503a4b805b9c6fa' }
      allow(checksum_provider).to receive(:checksum).with('/test/directory/itemA/track01.wav') { 'd72880438ba42224b9dd185e4e8c1b60e6ddf61d977d0b99aed72bb9f964657b' }
      allow(checksum_provider).to receive(:checksum).with('/test/directory/itemB/file02.pdf') { 'a2b872e2a3958a1ec7de3afcfd017d323c0a43dcebf0e607ab31acde4799aa8f' }
      allow(checksum_provider).to receive(:checksum).with('/test/directory/itemB/track02.wav') { 'dd60f671e6f31c75f11643e98384f71864ee654c6afb9d26cdc6a7c458741d47' }
    end

    context 'collection repository ID not provided' do
      let(:batch_builder) { described_class.new(user: user, filesystem: filesystem,
                                                content_modeler: content_modeler, checksum_provider: checksum_provider,
                                                admin_set: admin_set, collection_title: collection_title,
                                                batch_name: batch_name, batch_description: batch_description) }
      it_behaves_like "a successfully built nested folder ingest batch" do
        let(:batch) { batch_builder.call }
        let(:coll_count) { 1 }
        let(:coll_id) { collections.first.pid }
      end
    end

    context 'collection repository ID provided' do
      let(:collection_id) { 'test:abcd' }
      let(:batch_builder) { described_class.new(user: user, filesystem: filesystem,
                                                content_modeler: content_modeler,
                                                checksum_provider: checksum_provider,
                                                collection_repo_id: collection_id, batch_name: batch_name,
                                                batch_description: batch_description) }
      before do
        allow_any_instance_of(Ddr::Batch::Batch).to receive(:found_pids) { { collection_id => 'Collection' } }
      end

      it_behaves_like "a successfully built nested folder ingest batch" do
        let(:batch) { batch_builder.call }
        let(:coll_count) { 0 }
        let(:coll_id) { collection_id }
      end
    end

  end

end
