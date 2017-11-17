require 'spec_helper'
require 'support/ingest_folder_helper'

RSpec.shared_examples 'a successfully built datastream upload batch' do
  it 'builds an appropriate batch' do
    # Batch expectations
    expect(batch.id).to be_present
    expect(batch.name).to eq(batch_name)
    expect(batch.description).to eq(batch_description)
    expect(batch.collection_id).to eq(collection_id)
    expect(batch.collection_title).to eq(collection_title)
    expect(batch.status).to eq(Ddr::Batch::Batch::STATUS_READY)

    # Batch object expectations
    expect(batch_objects.count).to eq(3)
    batch_object_filepaths = {}
    batch_object_checksums = {} if defined?(checksums)
    batch_objects.each do |obj|
      expect(obj.type).to eq('Ddr::Batch::UpdateBatchObject')
      expect(obj.pid).to_not be_nil
      batch_object_datastreams = obj.batch_object_datastreams
      expect(batch_object_datastreams.size).to eq(1)
      batch_object_datastream = batch_object_datastreams.first
      expect(batch_object_datastream.name).to eq(datastream_name)
      expect(batch_object_datastream.operation).to eq(Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE)
      expect(batch_object_datastream.payload_type).to eq(Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
      batch_object_filepaths[obj.pid] = batch_object_datastream.payload
      if defined?(checksums)
        expect(batch_object_datastream.checksum_type).to eq(Ddr::Datastreams::CHECKSUM_TYPE_SHA1)
        batch_object_checksums[obj.pid] = batch_object_datastream.checksum
      end
    end
    expect(batch_object_filepaths).to match(expected_filepaths)
    expect(batch_object_checksums).to match(expected_checksums) if defined?(checksums)
  end
end

RSpec.describe BuildBatchFromDatastreamUpload, type: :service, batch: true do

  let(:batch_builder) { described_class.new(builder_args) }
  let(:batch_description) { 'Testing datastream upload batch building' }
  let(:batch_name) { 'Test Datastream Upload Batch' }
  let(:batch_objects) { batch.batch_objects }
  let(:collection_id) { 'test:17' }
  let(:collection_title) { 'Test Collection' }
  let(:collection) { Collection.new(pid: collection_id, title: [ collection_title ]) }
  let(:datastream_name) { Ddr::Datastreams::INTERMEDIATE_FILE }
  let(:expected_filepaths) { { 'test:22' => '/test/directory/abc001.jpg',
                               'test:25' => '/test/directory/abc002.jpg',
                               'test:28' => '/test/directory/abc003.jpg' } }
  let(:filesystem) { Filesystem.new }
  let(:user) { FactoryGirl.create(:user) }

  describe 'datastream upload' do
    before do
      filesystem.tree = filesystem_datastream_uploads
      allow(batch_builder).to receive(:matching_component_query_by_local_id).with(collection, 'abc001') { double('Ddr::Index::Query', ids: [ 'test:22' ]) }
      allow(batch_builder).to receive(:matching_component_query_by_local_id).with(collection, 'abc002') { double('Ddr::Index::Query', ids: [ 'test:25' ]) }
      allow(batch_builder).to receive(:matching_component_query_by_local_id).with(collection, 'abc003') { double('Ddr::Index::Query', ids: [ 'test:28' ]) }
    end
    describe 'checksum file not provided' do
      let(:builder_args) { { batch_description: batch_description, batch_name: batch_name,
                             batch_user: user, collection: collection, datastream_name: datastream_name,
                             filesystem: filesystem } }
      it_behaves_like 'a successfully built datastream upload batch' do
        let(:batch) { batch_builder.call }
      end
    end
    describe 'checksum file provided' do
      let(:checksum_file_path) { '/tmp/checksums.txt' }
      let(:checksums) { { '/test/directory/abc001.jpg' => '03f717284d2f8c5ffb0714cb85d1d6689cffa0b0',
                          '/test/directory/abc002.jpg' => '75e2e0cec6e807f6ae63610d46448f777591dd6b',
                          '/test/directory/abc003.jpg' => '2cf23f0035c12b6242093e93d0f7eeba0b1e08e8' } }
      let(:expected_checksums) { { 'test:22' => checksums['/test/directory/abc001.jpg'],
                                   'test:25' => checksums['/test/directory/abc002.jpg'] ,
                                   'test:28' => checksums['/test/directory/abc003.jpg'] } }
      let(:builder_args) { { batch_description: batch_description, batch_name: batch_name,
                             batch_user: user, checksum_file_path: checksum_file_path, collection: collection,
                             datastream_name: datastream_name, filesystem: filesystem } }
      before do
        checksums.each do |key, value|
          allow_any_instance_of(IngestChecksum).to receive(:checksum).with(key) { value }
        end
      end
      it_behaves_like 'a successfully built datastream upload batch' do
        let(:batch) { batch_builder.call }
      end
    end
  end
  describe 'component matching' do
    let(:component) { FactoryGirl.build(:component) }
    let(:collection) { Collection.create(title: ['Test Collection' ], admin_set: 'dc') }
    let(:builder_args) { { batch_description: batch_description, batch_name: batch_name,
                           batch_user: user, collection: collection, datastream_name: datastream_name,
                           filesystem: filesystem } }
    before do
      filesystem.tree = filesystem_single_datastream_upload
      component.admin_policy = collection
      component.save!
    end
    describe 'no match by local_id or filename' do
      it 'should raise an error' do
        expect { batch_builder.call }.to raise_error(DulHydra::Error, /Unable to find matching component/)
      end
    end
    describe 'match by local_id' do
      before do
        component.update_attributes(local_id: 'abc001')
      end
      it 'should find the correct component' do
        batch = batch_builder.call
        expect(batch.batch_objects.first.pid).to eq(component.pid)
      end
    end
    describe 'match by filename but not local_id' do
      before do
        component.update_attributes(original_filename: 'abc001.tif')
      end
      it 'should find the correct component' do
        batch = batch_builder.call
        expect(batch.batch_objects.first.pid).to eq(component.pid)
      end
    end
  end
end
