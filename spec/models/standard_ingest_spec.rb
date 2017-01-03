require 'spec_helper'

RSpec.describe StandardIngest, type: :model, batch: true, ingest: true do

  let(:user) { FactoryGirl.create(:user) }
  let(:folder_path) { '/test/directory' }
  let(:filesystem) { Filesystem.new }
  let(:fs_node_paths) { filesystem.each_leaf.map { |leaf| Filesystem.node_locator(leaf) } }
  let(:standard_ingest_metadata) { double(StandardIngestMetadata) }

  subject { StandardIngest.new('batch_user' => user.user_key, 'folder_path' => folder_path) }

  describe 'validation' do
    before do
      filesystem.tree = sample_filesystem
      allow(Dir).to receive(:exist?).with(folder_path) { true }
      allow(Dir).to receive(:exist?).with(subject.data_path) { true }
      allow(File).to receive(:exist?).with(subject.checksum_path) { true }
      allow(File).to receive(:exist?).with(subject.metadata_path) { true }
      allow(subject).to receive(:metadata_provider) { standard_ingest_metadata }
      allow(subject).to receive(:filesystem_node_paths) { fs_node_paths }
    end
    describe 'metadata file' do
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
          expect(subject.errors.messages).to include({ metadata_file: [ "Metadata line for locator 'bar' will not be used" ] })
        end
      end
    end
  end
end
