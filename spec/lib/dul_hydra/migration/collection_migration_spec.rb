require 'spec_helper'

module DulHydra
  module Migration
    RSpec.describe CollectionMigration do

      let(:collection_pid) { 'test:1' }
      let(:item_pid) { 'test:2' }
      let(:component_pid) { 'test:3' }
      let(:attachment_pid) { 'test:4' }
      let(:target_pid) { 'test:5' }

      let(:object_ids) { [ collection_pid, item_pid, component_pid, attachment_pid, target_pid ] }

      let(:file_to_write) { '/path/to/collection/migration/file.txt' }

      before do
        collection = Collection.create(pid: collection_pid, admin_set: 'foo', title: [ 'Test Collection' ])
        item = Item.create(pid: item_pid, parent: collection, admin_policy: collection)
        Component.create(pid: component_pid, parent: item, admin_policy: collection)
        Attachment.create(pid: attachment_pid, attached_to: collection, admin_policy: collection)
        Target.create(pid: target_pid, collection: collection, admin_policy: collection)
      end

      it 'creates a CSV file for the collection and all its associated objects' do
        expect(MigrationMetadataTable).to receive(:new).with(object_ids).and_call_original
        expect_any_instance_of(MigrationMetadataTable).to receive(:write_to_file).with(file_to_write)
        described_class.call(collection_pid, file_to_write)
      end
    end
  end
end
