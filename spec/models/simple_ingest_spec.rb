require 'spec_helper'

RSpec.describe SimpleIngest, type: :model, simple_ingest: true do

  subject { SimpleIngest.new(simple_ingest_args) }

  let(:user) { FactoryGirl.create(:user) }
  let(:simple_ingest_metadata) { double(SimpleIngestMetadata) }
  let(:simple_ingest_checksum) { double(SimpleIngestChecksum) }
  let(:filesystem) { filesystem_simple_ingest }
  let(:admin_set) { 'dvs' }

  before do
    allow(SimpleIngestMetadata).to receive(:new) { simple_ingest_metadata }
    allow(SimpleIngestChecksum).to receive(:new) { simple_ingest_checksum }
  end

  describe "collection creating simple ingest" do
    let(:simple_ingest_args) { { 'admin_set' => admin_set,
                                 'folder_path' => '/foo/bar',
                                 'batch_user' => user.user_key } }
    let(:batch_builder_args) { { user: user,
                                 filesystem: filesystem,
                                 content_modeler: ModelSimpleIngestContent,
                                 metadata_provider: simple_ingest_metadata,
                                 checksum_provider: simple_ingest_checksum,
                                 batch_name: "Simple Ingest",
                                 batch_description: filesystem.root.name,
                                 admin_set: admin_set } }
    before do
      expect(BuildBatchFromFolderIngest).to receive(:new).with(batch_builder_args).and_call_original
      allow_any_instance_of(BuildBatchFromFolderIngest).to receive(:call) { nil }
    end
    it "calls the batch builder correctly" do
      subject.build_batch(filesystem)
    end
  end

  describe "item adding simple ingest" do
    let(:collection_repo_id) { 'test:1' }
    let(:simple_ingest_args) { { 'admin_set' => admin_set,
                                 'collection_id' => collection_repo_id,
                                 'folder_path' => '/foo/bar',
                                 'batch_user' => user.user_key } }
    let(:batch_builder_args) { { user: user,
                                 filesystem: filesystem,
                                 content_modeler: ModelSimpleIngestContent,
                                 metadata_provider: simple_ingest_metadata,
                                 checksum_provider: simple_ingest_checksum,
                                 batch_name: "Simple Ingest",
                                 batch_description: filesystem.root.name,
                                 admin_set: admin_set,
                                 collection_repo_id: collection_repo_id } }
    before do
      expect(BuildBatchFromFolderIngest).to receive(:new).with(batch_builder_args).and_call_original
      allow_any_instance_of(BuildBatchFromFolderIngest).to receive(:call) { nil }
    end
    it "calls the batch builder correctly" do
      subject.build_batch(filesystem)
    end
  end

end
