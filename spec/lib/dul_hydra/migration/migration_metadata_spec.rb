require 'spec_helper'

module DulHydra
  module Migration
    RSpec.describe MigrationMetadata, migration: true do

      subject { described_class.new(object) }

      let(:admin_metadata_attrs) do
        { admin_set: [ 'foo' ],
          affiliation: [ 'alpha', 'beta', 'gamma' ] }
      end
      let(:desc_metadata_attrs) do
        { creator: [ 'foo', 'bar' ],
          identifier: [ 'obj00001' ],
          title: [ 'Test Object' ] }
      end
      let(:base_attrs) { admin_metadata_attrs.merge(desc_metadata_attrs)}

      describe 'collection' do
        let(:object_attrs) { base_attrs }
        let(:object) { Collection.create(object_attrs) }
        let(:admin_policy_metadata) { { admin_policy: object.pid } }
        let(:misc_metadata) do
          { access_role: object.adminMetadata.access_role,
            ingestion_date: object.adminMetadata.ingestion_date }
        end
        let(:system_metadata) do
          { create_date: object.create_date,
            model: object.class.name,
            modified_date: object.modified_date,
            pid: object.pid }
        end
        let(:migration_metadata) do
          base_attrs.
              merge(admin_policy_metadata).
              merge(misc_metadata).
              merge(system_metadata)
        end
        specify do
          expect(subject.migration_metadata).to match(migration_metadata)
        end
      end

      describe 'item' do
        let(:collection_pid) { 'test:1' }
        let(:collection) { Collection.new(pid: collection_pid) }
        let(:admin_policy_attrs) { { admin_policy: collection } }
        let(:parent_attrs) { { parent: collection } }
        let(:object_attrs) { base_attrs.merge(admin_policy_attrs).merge(parent_attrs) }
        let(:object) { Item.create(object_attrs) }
        let(:admin_policy_metadata) { { admin_policy: collection.pid } }
        let(:misc_metadata) { { ingestion_date: object.adminMetadata.ingestion_date } }
        let(:parent_metadata) { { parent: collection.pid } }
        let(:system_metadata) do
          { create_date: object.create_date,
            model: object.class.name,
            modified_date: object.modified_date,
            pid: object.pid }
        end
        let(:migration_metadata) do
          base_attrs.
              merge(admin_policy_metadata).
              merge(misc_metadata).
              merge(parent_metadata).
              merge(system_metadata)
        end
        specify do
          expect(subject.migration_metadata).to match(migration_metadata)
        end
      end

      describe 'component' do
        let(:collection_pid) { 'test:1' }
        let(:collection) { Collection.new(pid: collection_pid) }
        let(:item_pid) { 'test:2' }
        let(:item) { Item.new(pid: item_pid) }
        let(:admin_policy_attrs) { { admin_policy: collection } }
        let(:parent_attrs) { { parent: item } }
        let(:object_attrs) { base_attrs.merge(admin_policy_attrs).merge(parent_attrs) }
        let(:object) { Component.create(object_attrs) }
        let(:admin_policy_metadata) { { admin_policy: collection.pid } }
        let(:misc_metadata) { { ingestion_date: object.adminMetadata.ingestion_date } }
        let(:parent_metadata) { { parent: item.pid } }
        let(:system_metadata) do
          { create_date: object.create_date,
            model: object.class.name,
            modified_date: object.modified_date,
            pid: object.pid }
        end
        let(:migration_metadata) do
          base_attrs.
              merge(admin_policy_metadata).
              merge(misc_metadata).
              merge(parent_metadata).
              merge(system_metadata)
        end
        specify do
          expect(subject.migration_metadata).to match(migration_metadata)
        end
      end

      describe 'attachment' do
        let(:collection_pid) { 'test:1' }
        let(:collection) { Collection.new(pid: collection_pid) }
        let(:admin_policy_attrs) { { admin_policy: collection } }
        let(:attached_to_attrs) { { attached_to: collection } }
        let(:object_attrs) { base_attrs.merge(admin_policy_attrs).merge(attached_to_attrs) }
        let(:object) { Attachment.create(object_attrs) }
        let(:admin_policy_metadata) { { admin_policy: collection.pid } }
        let(:attached_to_metadata) { { attached_to: collection.pid } }
        let(:misc_metadata) { { ingestion_date: object.adminMetadata.ingestion_date } }
        let(:system_metadata) do
          { create_date: object.create_date,
            model: object.class.name,
            modified_date: object.modified_date,
            pid: object.pid }
        end
        let(:migration_metadata) do
          base_attrs.
              merge(admin_policy_metadata).
              merge(attached_to_metadata).
              merge(misc_metadata).
              merge(system_metadata)
        end
        specify do
          expect(subject.migration_metadata).to match(migration_metadata)
        end
      end

      describe 'target' do
        let(:collection_pid) { 'test:1' }
        let(:collection) { Collection.new(pid: collection_pid) }
        let(:admin_policy_attrs) { { admin_policy: collection } }
        let(:external_target_for_attrs) { { collection: collection } }
        let(:object_attrs) { base_attrs.merge(admin_policy_attrs).merge(external_target_for_attrs) }
        let(:object) { Target.create(object_attrs) }
        let(:admin_policy_metadata) { { admin_policy: collection.pid } }
        let(:external_target_for_metadata) { { external_target_for: collection.pid } }
        let(:misc_metadata) { { ingestion_date: object.adminMetadata.ingestion_date } }
        let(:system_metadata) do
          { create_date: object.create_date,
            model: object.class.name,
            modified_date: object.modified_date,
            pid: object.pid }
        end
        let(:migration_metadata) do
          base_attrs.
              merge(admin_policy_metadata).
              merge(external_target_for_metadata).
              merge(misc_metadata).
              merge(system_metadata)
        end
        specify do
          expect(subject.migration_metadata).to match(migration_metadata)
        end
      end

      describe '#admin_metadata' do
        let(:object) { Ddr::Models::Base.new(base_attrs) }
        it 'returns a hash of administrative metadata attributes' do
          expect(subject.admin_metadata).to match(admin_metadata_attrs)
        end
      end

      describe '#desc_metadata' do
        let(:object) { Ddr::Models::Base.new(base_attrs) }
        it 'returns a hash of descriptive metadata attributes' do
          expect(subject.desc_metadata).to match(desc_metadata_attrs)
        end
      end

      describe '#relationships' do
        describe 'admin policy' do
          let(:collection_pid) { 'test:1' }
          let(:collection) { Collection.new(pid: collection_pid) }
          let(:admin_policy_attr) do
            { admin_policy: collection }
          end
          let(:object) { Ddr::Models::Base.new(base_attrs.merge(admin_policy_attr)) }
          specify do
            expect(subject.relationships).to match({ admin_policy: collection.pid })
          end
        end
        describe 'attached to' do
          let(:collection_pid) { 'test:1' }
          let(:collection) { Collection.new(pid: collection_pid) }
          let(:attached_to_attr) do
            { attached_to: collection }
          end
          let(:object) { Attachment.new(base_attrs.merge(attached_to_attr)) }
          specify do
            expect(subject.relationships).to match({ attached_to: collection.pid })
          end
        end
        describe 'external target for' do
          let(:collection_pid) { 'test:1' }
          let(:collection) { Collection.new(pid: collection_pid) }
          let(:external_target_for_attr) do
            { collection: collection }
          end
          let(:object) { Target.new(base_attrs.merge(external_target_for_attr)) }
          specify do
            expect(subject.relationships).to match({ external_target_for: collection.pid })
          end
        end
        describe 'parentage' do
          describe 'item' do
            let(:parent_pid) { 'test:1' }
            let(:parent) { Collection.new(pid: parent_pid) }
            let(:parent_attr) do
              { parent: parent }
            end
            let(:object) { Item.new(base_attrs.merge(parent_attr)) }
            specify do
              expect(subject.relationships).to match({ parent: parent.pid })
            end
          end
          describe 'component' do
            let(:parent_pid) { 'test:1' }
            let(:parent) { Item.new(pid: parent_pid) }
            let(:parent_attr) do
              { parent: parent }
            end
            let(:object) { Component.new(base_attrs.merge(parent_attr)) }
            specify do
              expect(subject.relationships).to match({ parent: parent.pid })
            end
          end
        end
      end

      describe '#system_data' do
        let(:object) { Ddr::Models::Base.create }
        let(:system_data) do
          { create_date: object.create_date,
            model: object.class.name,
            modified_date: object.modified_date,
            pid: object.pid }
        end
        specify do
          expect(subject.system_data).to match(system_data)
        end
      end

    end
  end
end
