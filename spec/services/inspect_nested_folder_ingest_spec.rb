require 'spec_helper'
require 'support/ingest_folder_helper'

RSpec.describe InspectNestedFolderIngest, type: :service, batch: true, nested_folder_ingest: true do

  let(:filepath) { "/foo/bar" }
  let(:inspect_nested_folder_ingest) { InspectNestedFolderIngest.new(filepath, nested_folder_ingest_configuration[:scanner]) }
  let(:filesystem) { Filesystem.new }
  let(:scan_results) { ScanFilesystem::Results.new(filesystem, []) }

  before do
    allow(Dir).to receive(:exist?) { true }
    allow(File).to receive(:readable?).with(filepath) { true }
    allow_any_instance_of(ScanFilesystem).to receive(:call) { scan_results }
    filesystem.tree = sample_filesystem
  end

  describe "nested folder ingest folder" do
    describe "filepath" do
      context 'valid filepath' do
        it "should not raise an error" do
          expect { inspect_nested_folder_ingest.call }.to_not raise_error
        end
      end
      context "filepath does not point to an existing directory" do
        before { allow(Dir).to receive(:exist?) { false } }
        it "should raise a not found or not directory error" do
          expect { inspect_nested_folder_ingest.call }.to raise_error(DulHydra::BatchError, /not found or is not a directory/)
        end
      end
      context "filepath is not readable" do
        before do
          allow(File).to receive(:readable?).with(filepath) { false }
        end
        it "should raise a not readable error" do
          expect { inspect_nested_folder_ingest.call }.to raise_error(DulHydra::BatchError, /not readable/)
        end
      end
    end
  end

  describe "filesystem" do
    context "valid for nested folder ingest" do
      it "should report the number of files" do
        expect(inspect_nested_folder_ingest.call.file_count).to eq(6)
      end
      it "should report the excluded files/folders" do
        expect(inspect_nested_folder_ingest.call.exclusions).to eq([])
      end
      it "should report the content model stats" do
        stats = inspect_nested_folder_ingest.call.content_model_stats
        expect(stats).to include(collections: 1)
        expect(stats).to include(items: 6)
        expect(stats).to include(components: 6)
      end
      it "should report the filesystem object" do
        expect(inspect_nested_folder_ingest.call.filesystem).to be_a(Filesystem)
      end
    end
  end

end
