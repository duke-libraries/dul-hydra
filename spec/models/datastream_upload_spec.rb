require 'spec_helper'

RSpec.describe DatastreamUpload, type: :model, batch: true  do

  subject { described_class.new(ingest_args) }

  describe "#build_batch" do
    let(:user) { FactoryGirl.create(:user) }
    let(:basepath) { '/test/' }
    let(:batch_description) { filesystem.root.name }
    let(:batch_name) { 'Datastream Upload' }
    let(:datastream_name) { Ddr::Datastreams::INTERMEDIATE_FILE }
    let(:collection) { double('Collection', id: 'test:17') }
    let(:subpath) { 'directory/' }
    let(:filesystem) { sample_filesystem_without_dot_files }
    let(:fs_node_paths) { filesystem.each_leaf.map { |leaf| Filesystem.node_locator(leaf) } }
    let(:test_config_file) do
      Rails.root.join('spec', 'fixtures', 'batch_update', 'datastream_upload', 'datastream_upload.yml')
    end

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(DatastreamUpload::DEFAULT_CONFIG_FILE) { File.read(test_config_file) }
      allow(subject).to receive(:filesystem) { filesystem }
      allow_any_instance_of(BuildBatchFromDatastreamUpload).to receive(:call) { nil }
    end

    describe "without checksums" do
      let(:ingest_args) { { 'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'collection_id' => collection.id,
                            'datastream_name' => datastream_name,
                            'subpath' => subpath } }
      let(:batch_builder_args) { { batch_description: batch_description,
                                   batch_name: batch_name,
                                   batch_user: user,
                                   datastream_name: datastream_name,
                                   filesystem: filesystem,
                                   collection: collection.id } }
      it "calls the batch builder correctly" do
        expect(BuildBatchFromDatastreamUpload).to receive(:new).with(batch_builder_args).and_call_original
        subject.build_batch
      end
    end

    describe "with checksums" do
      let(:checksum_file) { 'checksums.txt' }
      let(:checksum_location) { '/tmp/test/' }
      let(:ingest_args) { { 'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'checksum_file' => checksum_file,
                            'checksum_location' => checksum_location,
                            'collection_id' => collection.id,
                            'datastream_name' => datastream_name,
                            'subpath' => subpath } }
      let(:batch_builder_args) { { batch_description: batch_description,
                                   batch_name: batch_name,
                                   batch_user: user,
                                   datastream_name: datastream_name,
                                   filesystem: filesystem,
                                   checksum_file_path: File.join(checksum_location, checksum_file),
                                   collection: collection.id } }
      it "calls the batch builder correctly" do
        expect(BuildBatchFromDatastreamUpload).to receive(:new).with(batch_builder_args).and_call_original
        subject.build_batch
      end
    end

  end

end
