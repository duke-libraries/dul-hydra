require 'spec_helper'

RSpec.describe StandardIngest, type: :model, batch: true, ingest: true do

  let(:user) { FactoryGirl.create(:user) }
  let(:folder_path) { '/test/directory' }
  let(:fs_node_paths) { filesystem.each_leaf.map { |leaf| Filesystem.node_locator(leaf) } }
  let(:standard_ingest_metadata) { double(StandardIngestMetadata) }

  subject { StandardIngest.new(standard_ingest_args) }

  describe 'validation' do
    let(:filesystem) { Filesystem.new }
    let(:standard_ingest_args) { { 'batch_user' => user.user_key,
                                   'folder_path' => folder_path } }
    before do
      filesystem.tree = sample_filesystem
      allow(Dir).to receive(:exist?).with(folder_path) { true }
      allow(Dir).to receive(:exist?).with(subject.data_path) { true }
      allow(File).to receive(:exist?).with(subject.checksum_path) { true }
      allow(subject).to receive(:metadata_provider) { standard_ingest_metadata }
      allow(subject).to receive(:filesystem_node_paths) { fs_node_paths }
    end
    describe 'metadata file' do
      before { allow(subject).to receive(:inspection_results) { nil } }
      describe 'present' do
        before { allow(File).to receive(:exist?).with(subject.metadata_path) { true } }
        describe 'valid locators' do
          before { allow(standard_ingest_metadata).to receive(:locators) { fs_node_paths } }
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
        describe 'invalid locators' do
          before { allow(standard_ingest_metadata).to receive(:locators) { fs_node_paths + [ 'bar' ] } }
          it "should not be valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to include(
                 { metadata_file: [ I18n.t('dul_hydra.standard_ingest.validation.missing_folder_file', miss: 'bar') ] })
          end
        end
      end
      describe 'not present' do
        before { allow(File).to receive(:exist?).with(subject.metadata_path) { false } }
        describe 'collection creating ingest' do
          it "should not be valid" do
            expect(subject).to_not be_valid
            expect(subject.errors.messages).to include({ folder_path: [ "#{subject.metadata_path} does not exist" ] })
          end
        end
        describe 'item adding ingest' do
          let(:collection_repo_id) { 'test:1' }
          let(:standard_ingest_args) { { 'batch_user' => user.user_key,
                                         'folder_path' => folder_path,
                                         'collection_id' => collection_repo_id } }
          before { allow(Collection).to receive(:exists?).with(collection_repo_id) { true } }
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
    describe 'invalid standard ingest folder' do
      let(:error_message) { "#{File.join(folder_path, 'data')} is not a valid standard ingest directory" }
      before do
        allow(File).to receive(:exist?).with(subject.metadata_path) { false }
        allow(subject).to receive(:inspection_results).and_raise(DulHydra::BatchError, error_message)
      end
      it "should not be valid" do
        expect(subject).to_not be_valid
        expect(subject.errors.messages[:folder_path]).to include(error_message)
      end
    end
  end

  describe "#build_batch" do
    let(:intermediate_files_name) { 'intermediate_files' }
    let(:targets_name) { 'dpc_targets' }
    let(:standard_ingest_metadata) { double(StandardIngestMetadata) }
    let(:standard_ingest_checksum) { double(StandardIngestChecksum) }
    let(:filesystem) { filesystem_standard_ingest }
    let(:config) { {:scanner=>{:exclude=>[".DS_Store", "Thumbs.db", "metadata.txt"], :targets=>"dpc_targets",
                               :intermediate_files=>"intermediate_files"},
                    :metadata=>{:csv=>{:encoding=>"UTF-8", :headers=>true, :col_sep=>"\t"},
                                :parse=>{:repeating_fields_separator=>";",
                                         :repeatable_fields=>["contributor", "coverage", "creator", "extent",
                                                              "identifier", "rightsHolder", "subject", "temporal"]}}} }
    let(:admin_set) { 'dvs' }

    before do
      allow(StandardIngestMetadata).to receive(:new) { standard_ingest_metadata }
      allow(StandardIngestChecksum).to receive(:new) { standard_ingest_checksum }
      allow(File).to receive(:exist?).with(subject.metadata_path) { true }
      allow(subject).to receive(:filesystem) { filesystem }
      allow(subject).to receive(:configuration) { config }
    end

    describe "collection creating standard ingest" do
      let(:standard_ingest_args) { { 'admin_set' => admin_set,
                                     'folder_path' => folder_path,
                                     'batch_user' => user.user_key } }
      let(:batch_builder_args) { { user: user,
                                   filesystem: filesystem,
                                   intermediate_files_name: intermediate_files_name,
                                   targets_name: targets_name,
                                   content_modeler: ModelStandardIngestContent,
                                   metadata_provider: standard_ingest_metadata,
                                   checksum_provider: standard_ingest_checksum,
                                   batch_name: "Standard Ingest",
                                   batch_description: filesystem.root.name,
                                   admin_set: admin_set } }
      before do
        expect(BuildBatchFromFolderIngest).to receive(:new).with(batch_builder_args).and_call_original
        allow_any_instance_of(BuildBatchFromFolderIngest).to receive(:call) { nil }
      end
      it "calls the batch builder correctly" do
        subject.build_batch
      end
    end

    describe "item adding standard ingest" do
      let(:collection_repo_id) { 'test:1' }
      let(:standard_ingest_args) { { 'admin_set' => admin_set,
                                     'collection_id' => collection_repo_id,
                                     'folder_path' => folder_path,
                                     'batch_user' => user.user_key } }
      let(:batch_builder_args) { { user: user,
                                   filesystem: filesystem,
                                   intermediate_files_name: intermediate_files_name,
                                   targets_name: targets_name,
                                   content_modeler: ModelStandardIngestContent,
                                   metadata_provider: standard_ingest_metadata,
                                   checksum_provider: standard_ingest_checksum,
                                   batch_name: "Standard Ingest",
                                   batch_description: filesystem.root.name,
                                   admin_set: admin_set,
                                   collection_repo_id: collection_repo_id } }
      before do
        expect(BuildBatchFromFolderIngest).to receive(:new).with(batch_builder_args).and_call_original
        allow_any_instance_of(BuildBatchFromFolderIngest).to receive(:call) { nil }
      end
      it "calls the batch builder correctly" do
        subject.build_batch
      end
    end
  end

end
