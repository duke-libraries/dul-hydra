require 'migration_helper'

module DulHydra::Migration
  RSpec.describe MigrateListObjectStructMetadata do

    subject { described_class.new(pid_list_file_path) }

    let(:pid_list_file_path) { 'pid_list.txt' }
    let(:pid_list_file) { double('file') }
    let(:test1_rep) { double(fcrepo4_id: 'ab', model: 'Item', struct_metadata_status: nil) }
    let(:test2_rep) { double(fcrepo4_id: 'cd', model: 'Component', struct_metadata_status: nil) }
    let(:test3_rep) { double(fcrepo4_id: 'ef', model: 'Item', struct_metadata_status: MigrationReport::MIGRATION_SUCCESS) }

    before do
      allow(File).to receive(:open).with(pid_list_file_path) { pid_list_file }
      allow(pid_list_file).to receive(:each_line).and_yield('test:1').and_yield('test:2').and_yield('test:3')
      allow(DulHydra::Migration::MigrationReport).to receive(:where).with({ fcrepo3_pid: "test:1" }) { [ test1_rep ] }
      allow(DulHydra::Migration::MigrationReport).to receive(:where).with({ fcrepo3_pid: "test:2" }) { [ test2_rep ] }
      allow(DulHydra::Migration::MigrationReport).to receive(:where).with({ fcrepo3_pid: "test:3" }) { [ test3_rep ] }
    end

    it "should migrate the struct metadata for unmigrated item objects" do
      expect(Resque).to receive(:enqueue).with(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, 'ab')
      expect(Resque).to_not receive(:enqueue).with(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, 'cd')
      expect(Resque).to_not receive(:enqueue).with(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, 'ef')
      subject.migrate
    end

  end
end
