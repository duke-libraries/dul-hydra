require 'spec_helper'

module DulHydra
  module Migration
    RSpec.describe MigrationMetadataTable, migration: true do

      let(:collection_pid) { 'test:1' }
      let(:item_pid) { 'test:2' }
      let(:component_pid) { 'test:3' }
      let(:attachment_pid) { 'test:4' }
      let(:target_pid) { 'test:5' }

      let(:object_ids) { [ collection_pid, item_pid, component_pid, attachment_pid, target_pid ] }

      let(:collection) { Collection.new(pid: collection_pid) }
      let(:item) { Item.new(pid: item_pid) }
      let(:component) { Component.new(pid: component_pid) }
      let(:attachment) { Attachment.new(pid: attachment_pid) }
      let(:target) { Target.new(pid: target_pid) }

      let(:base_metadata) do
        { admin_policy: collection.pid,
          admin_set: [ 'foo' ],
          affiliation: [ 'alpha', 'beta', 'gamma' ],
          create_date: '2019-08-09T15:44:58Z',
          creator: [ 'foo', 'bar' ],
          identifier: [ 'obj00001' ],
          ingestion_date: '2019-08-09T15:44:58Z',
          modified_date: '2019-08-09T16:42:08Z',
          title: [ 'Test Object' ] }
      end

      let(:collection_metadata) do
        base_metadata.merge({ model: 'Collection', pid: collection_pid })
      end

      let(:item_metadata) do
        base_metadata.merge({ model: 'Item', parent: collection_pid, pid: item_pid })
      end

      let(:component_metadata) do
        base_metadata.merge({ model: 'Compoonent', parent: item_pid, pid: component_pid })
      end

      let(:attachment_metadata) do
        base_metadata.merge({ attached_to: collection_pid, model: 'Attachment', pid: attachment_pid })
      end

      let(:target_metadata) do
        base_metadata.merge({ external_target_for: collection_pid, model: 'Target', pid: target_pid })
      end

      before do
        allow(ActiveFedora::Base).to receive(:find).with(collection_pid) { collection }
        allow(ActiveFedora::Base).to receive(:find).with(item_pid) { item }
        allow(ActiveFedora::Base).to receive(:find).with(component_pid) { component }
        allow(ActiveFedora::Base).to receive(:find).with(attachment_pid) { attachment }
        allow(ActiveFedora::Base).to receive(:find).with(target_pid) { target }
        allow(MigrationMetadata).to receive(:new).with(an_instance_of(Collection)) do
          double(migration_metadata: collection_metadata)
        end
        allow(MigrationMetadata).to receive(:new).with(an_instance_of(Item)) do
          double(migration_metadata: item_metadata)
        end
        allow(MigrationMetadata).to receive(:new).with(an_instance_of(Component)) do
          double(migration_metadata: component_metadata)
        end
        allow(MigrationMetadata).to receive(:new).with(an_instance_of(Attachment)) do
          double(migration_metadata: attachment_metadata)
        end
        allow(MigrationMetadata).to receive(:new).with(an_instance_of(Target)) do
          double(migration_metadata: target_metadata)
        end
      end

      subject { described_class.new(object_ids) }

      describe '#as_csv_table' do
        let(:headers) do
          [ :admin_set, :admin_policy, :affiliation, :affiliation, :affiliation, :attached_to, :create_date, :creator,
            :creator, :external_target_for, :identifier, :ingestion_date, :modified_date, :model, :parent, :pid,
            :title ]
        end
        specify do
          table = subject.as_csv_table
          expect(table).to be_a(CSV::Table)
          expect(table.headers).to match_array(headers)
          expect(table[:admin_set]).to eq([ 'foo', 'foo','foo','foo','foo' ])
          expect(table[:parent]).to eq([ nil, collection_pid, item_pid, nil, nil ])
          expect(table[:pid]).to eq([ collection_pid, item_pid, component_pid, attachment_pid, target_pid ])
          # Multi-valued attributes
          object_ids.each_with_index do |object_id, i|
            # affiliation
            idx = table.headers.index(:affiliation)
            expect(table[0][idx..idx+2]).to match_array([ 'alpha', 'beta', 'gamma' ])
            # creator
            idx = table.headers.index(:creator)
            expect(table[0][idx..idx+1]).to match_array([ 'foo', 'bar' ])
          end
        end
      end

      describe '#write_to_file' do
        let(:filename) { 'my_metadata.txt' }
        it 'writes the CSV table to the specified file' do
          Dir.mktmpdir do |tmpdir|
            filepath = File.join(tmpdir, filename)
            subject.write_to_file(filepath)
            expect(File.exists?(filepath)).to be true
          end
        end
        it 'is parseable as a CSV file' do
          Dir.mktmpdir do |tmpdir|
            filepath = File.join(tmpdir, filename)
            subject.write_to_file(filepath)
            expect{ CSV.read(filepath, DulHydra.csv_options) }.to_not raise_error
          end
        end
      end

    end
  end
end
