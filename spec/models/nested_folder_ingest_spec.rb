require 'spec_helper'

RSpec.describe NestedFolderIngest, type: :model, batch: true, ingest: true do

  subject { described_class.new(ingest_args) }

  describe "#build_batch" do
    let(:user) { FactoryGirl.create(:user) }
    let(:basepath) { '/test/' }
    let(:subpath) { 'directory/' }
    let(:ingest_checksum) { double(IngestChecksum) }
    let(:filesystem) { sample_filesystem }
    let(:fs_node_paths) { filesystem.each_leaf.map { |leaf| Filesystem.node_locator(leaf) } }
    let(:test_config_file) do
      Rails.root.join('spec', 'fixtures', 'batch_ingest', 'nested_folder_ingest', 'nested_folder_ingest.yml')
    end
    let(:admin_set) { 'dvs' }
    let(:collection_title) { 'My Collection' }

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(NestedFolderIngest::DEFAULT_CONFIG_FILE.to_s) { File.read(test_config_file) }
      allow(IngestChecksum).to receive(:new) { ingest_checksum }
      allow(subject).to receive(:filesystem) { filesystem }
      allow_any_instance_of(BuildBatchFromNestedFolderIngest).to receive(:call) { nil }
    end

    describe "collection creating nested folder ingest" do
      let(:ingest_args) { { 'admin_set' => admin_set,
                            'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'checksum_file' => 'my_checksums.txt',
                            'collection_title' => collection_title,
                            'subpath' => subpath } }
      let(:batch_builder_args) { { user: user,
                                   filesystem: filesystem,
                                   content_modeler: ModelNestedFolderIngestContent,
                                   batch_name: "Nested Folder Ingest",
                                   batch_description: filesystem.root.name,
                                   checksum_provider: ingest_checksum,
                                   admin_set: admin_set,
                                   collection_title: collection_title } }
      it "calls the batch builder correctly" do
        expect(BuildBatchFromNestedFolderIngest).to receive(:new).with(batch_builder_args).and_call_original
        subject.build_batch
      end
    end

    describe "item adding nested folder ingest" do
      let(:collection_repo_id) { 'test:1' }
      let(:ingest_args) { { 'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'checksum_file' => 'my_checksums.txt',
                            'collection_id' => collection_repo_id,
                            'subpath' => subpath } }
      let(:batch_builder_args) { { user: user,
                                   filesystem: filesystem,
                                   checksum_provider: ingest_checksum,
                                   content_modeler: ModelNestedFolderIngestContent,
                                   batch_name: "Nested Folder Ingest",
                                   batch_description: filesystem.root.name,
                                   collection_repo_id: collection_repo_id } }
      it "calls the batch builder correctly" do
        expect(BuildBatchFromNestedFolderIngest).to receive(:new).with(batch_builder_args).and_call_original
        subject.build_batch
      end
    end
  end

end
