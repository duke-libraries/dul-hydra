require 'spec_helper'

RSpec.describe NestedFolderIngest, type: :model, batch: true, ingest: true do

  subject { described_class.new(ingest_args) }

  describe "#build_batch" do
    let(:user) { FactoryGirl.create(:user) }
    let(:basepath) { '/test/' }
    let(:subpath) { 'directory/' }
    let(:ingest_checksum) { double(IngestChecksum) }
    let(:ingest_metadata) { double(IngestMetadata) }
    let(:filesystem) { sample_filesystem }
    let(:fs_node_paths) { filesystem.each_leaf.map { |leaf| Filesystem.path_to_node(leaf) } + [ nil ] }
    let(:test_config_file) do
      Rails.root.join('spec', 'fixtures', 'batch_ingest', 'nested_folder_ingest', 'nested_folder_ingest.yml')
    end
    let(:admin_set) { 'dvs' }
    let(:collection_title) { 'My Collection' }

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(NestedFolderIngest::DEFAULT_CONFIG_FILE.to_s) { File.read(test_config_file) }
      allow(IngestChecksum).to receive(:new) { ingest_checksum }
      allow(IngestMetadata).to receive(:new) { ingest_metadata }
      allow(subject).to receive(:filesystem) { filesystem }
      allow_any_instance_of(BuildBatchFromNestedFolderIngest).to receive(:call) { nil }
    end

    describe 'validation' do
      let(:ingest_args) { { 'admin_set' => admin_set,
                            'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'checksum_file' => 'my_checksums.txt',
                            'collection_title' => collection_title,
                            'metadata_file' => 'my_metadata.txt',
                            'subpath' => subpath } }
      before do
        allow(Dir).to receive(:exist?).with(File.join(basepath, subpath)) { true }
        allow(File).to receive(:exist?).with(subject.checksum_path) { true }
        allow(File).to receive(:exist?).with(subject.metadata_path) { true }
      end
      describe 'metadata file' do
        describe 'valid locators' do
          before { allow(ingest_metadata).to receive(:locators) { fs_node_paths } }
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
        describe 'invalid locators' do
          before { allow(ingest_metadata).to receive(:locators) { fs_node_paths + [ '/path/to/bar' ] } }
          it "should not be valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to include(
               { metadata_file: [ I18n.t('dul_hydra.nested_folder_ingest.validation.missing_file', miss: '/path/to/bar') ] })
          end
        end
      end
    end

    describe "collection creating nested folder ingest" do
      let(:ingest_args) { { 'admin_set' => admin_set,
                            'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'checksum_file' => 'my_checksums.txt',
                            'collection_title' => collection_title,
                            'metadata_file' => 'my_metadata.txt',
                            'subpath' => subpath } }
      let(:batch_builder_args) { { user: user,
                                   filesystem: filesystem,
                                   content_modeler: ModelNestedFolderIngestContent,
                                   metadata_provider: ingest_metadata,
                                   batch_name: "Nested Folder Ingest",
                                   batch_description: filesystem.root.name,
                                   checksum_provider: ingest_checksum,
                                   admin_set: admin_set,
                                   collection_title: collection_title } }
      it "calls the batch builder correctly" do
        expect(BuildBatchFromNestedFolderIngest).to receive(:new).with(match(batch_builder_args)).and_call_original
        subject.build_batch
      end
    end

    describe "item adding nested folder ingest" do
      let(:collection_repo_id) { 'test:1' }
      let(:ingest_args) { { 'basepath' => basepath,
                            'batch_user' => user.user_key,
                            'checksum_file' => 'my_checksums.txt',
                            'collection_id' => collection_repo_id,
                            'metadata_file' => 'my_metadata.txt',
                            'subpath' => subpath } }
      let(:batch_builder_args) { { user: user,
                                   filesystem: filesystem,
                                   checksum_provider: ingest_checksum,
                                   content_modeler: ModelNestedFolderIngestContent,
                                   batch_name: "Nested Folder Ingest",
                                   batch_description: filesystem.root.name,
                                   metadata_provider: ingest_metadata,
                                   collection_repo_id: collection_repo_id } }
      it "calls the batch builder correctly" do
        expect(BuildBatchFromNestedFolderIngest).to receive(:new).with(match(batch_builder_args)).and_call_original
        subject.build_batch
      end
    end
  end

end
