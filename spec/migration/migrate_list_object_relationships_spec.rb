require 'migration_helper'

module DulHydra::Migration
  RSpec.describe MigrateListObjectRelationships do

    subject { described_class.new(pid_list_file_path) }

    let(:pid_list_file_path) { 'pid_list.txt' }
    let(:pid_list_file) { double('file') }

    before do
      allow(File).to receive(:open).with(pid_list_file_path) { pid_list_file }
      allow(pid_list_file).to receive(:each_line).and_yield('test:1').and_yield('test:2')
    end

    it "should migrate the relationships for each object" do
      expect(Resque).to receive(:enqueue).with(DulHydra::Migration::MigrateSingleObjectRelationshipsJob, 'test:1')
      expect(Resque).to receive(:enqueue).with(DulHydra::Migration::MigrateSingleObjectRelationshipsJob, 'test:2')
      subject.migrate
    end

  end
end
