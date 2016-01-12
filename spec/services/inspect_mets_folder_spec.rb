require 'spec_helper'
require 'support/mets_folder_helper'

RSpec.describe InspectMETSFolder, type: :service, batch: true, mets_folder: true do

  let(:user) { FactoryGirl.create(:user) }
  let(:collection) { FactoryGirl.create(:collection) }
  let(:base_path) { '/foo/bar' }
  let(:sub_path) { 'baz' }
  let(:mets_folder_path) { File.join(base_path, sub_path) }
  let(:collection_id) { collection.id }
  let(:mets_folder) do
    METSFolder.new.tap do |mf|
      mf.user = user
      mf.base_path = base_path
      mf.sub_path = sub_path
      mf.collection_id = collection_id
    end
  end
  let(:mets_folder_config_file_path) { '/test/config/mets_folder.yml' }
  let(:mets_folder_config) { METSFolderConfiguration.new(mets_folder_config_file_path) }
  let(:filesystem) { Filesystem.new }
  let(:scan_results) { ScanFilesystem::Results.new(filesystem, []) }
  let(:validation_results) { ValidateMETSFile::Results.new([], [])}

  # before do
  #   allow(Dir).to receive(:exist?) { true }
  #   allow(File).to receive(:readable?).with(datapath) { true }
  #   allow(inspect_simple_ingest).to receive(:load_configuration) { simple_ingest_configuration }
  #   allow_any_instance_of(ScanFilesystem).to receive(:call) { scan_results }
  #   filesystem.tree = filesystem_simple_ingest
  # end



  before do
    allow(Dir).to receive(:exist?).with(mets_folder_path) { true }
    allow(File).to receive(:readable?).with(mets_folder_path) { true }
    allow(File).to receive(:read).with(mets_folder_config_file_path) { test_mets_folder_config }
    allow_any_instance_of(ScanFilesystem).to receive(:call) { scan_results }
    filesystem.tree = filesystem_mets_folder
    allow_any_instance_of(ValidateMETSFile).to receive(:call) { validation_results }
  end

  subject { InspectMETSFolder.new(mets_folder, mets_folder_config) }

  describe "mets folder" do
    describe "filepath" do
      context 'valid filepath' do
        it "should not raise an error" do
          expect { subject.call }.to_not raise_error
        end
      end
      context "folder path does not point to an existing directory" do
        before { allow(Dir).to receive(:exist?) { false } }
        it "should raise a not found or not directory error" do
          expect { subject.call }.to raise_error(DulHydra::BatchError, /not found or is not a directory/)
        end
      end
      context "folder path is not readable" do
        before do
          allow(File).to receive(:readable?).with(mets_folder_path) { false }
        end
        it "should raise a not readable error" do
          expect { subject.call }.to raise_error(DulHydra::BatchError, /not readable/)
        end
      end
    end
  end

  describe "filesystem" do
    context "valid for mets folder" do
      it "should report the number of files" do
        expect(subject.call.file_count).to eq(2)
      end
      it "should report the excluded files/folders" do
        expect(subject.call.exclusions).to eq([])
      end
      it "should report the filesystem object" do
        expect(subject.call.filesystem).to be_a(Filesystem)
      end
    end
    context "contains non-XML files" do
      before { filesystem.tree = filesystem_non_mets_folder }
      it "should raise a not valid error" do
        expect { subject.call }.to raise_error(DulHydra::BatchError, /does not appear to be a valid METS folder/)
      end
    end
  end

end
