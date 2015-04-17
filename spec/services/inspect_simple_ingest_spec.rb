require 'spec_helper'
require 'support/ingest_folder_helper'

RSpec.describe InspectSimpleIngest, type: :service, batch: true, simple_ingest: true do

  let(:filepath) { "/foo/bar" }
  let(:datapath) { File.join(filepath, 'data') }
  let(:inspect_simple_ingest) { InspectSimpleIngest.new(filepath, {}) }
  let(:filesystem) { Filesystem.new }
  let(:scan_results) { ScanFilesystem::Results.new(filesystem, []) }

  before do
    allow(Dir).to receive(:exist?) { true }
    allow(File).to receive(:readable?).with(datapath) { true }
    allow(inspect_simple_ingest).to receive(:load_configuration) { simple_ingest_configuration }
    allow_any_instance_of(ScanFilesystem).to receive(:call) { scan_results }
    filesystem.tree = filesystem_simple_ingest
  end

  describe "simple ingest folder" do
    describe "filepath" do
      context 'valid filepath' do
        it "should not raise an error" do
          expect { inspect_simple_ingest.call }.to_not raise_error
        end
      end
      context "filepath does not point to an existing directory" do
        before { allow(Dir).to receive(:exist?) { false } }
        it "should raise a not found or not directory error" do
          expect { inspect_simple_ingest.call }.to raise_error(DulHydra::BatchError, /not found or is not a directory/)
        end
      end
      context "filepath is not readable" do
        before do
          allow(File).to receive(:readable?).with(datapath) { false }
        end
        it "should raise a not readable error" do
          expect { inspect_simple_ingest.call }.to raise_error(DulHydra::BatchError, /not readable/)
        end
      end
    end
  end

  describe "filesystem" do
    context "valid for simple ingest" do
      it "should report the number of files" do
        expect(inspect_simple_ingest.call.file_count).to eq(6)
      end
      it "should report the excluded files/folders" do
        expect(inspect_simple_ingest.call.exclusions).to eq([])
      end
      it "should report the content model stats" do
        stats = inspect_simple_ingest.call.content_model_stats
        expect(stats).to include(collections: 1)
        expect(stats).to include(items: 4)
        expect(stats).to include(components: 6)
      end
      it "should report the filesystem object" do
        expect(inspect_simple_ingest.call.filesystem).to be_a(Filesystem)
      end
    end
    context "too deep for simple ingest" do
      before { filesystem.tree = filesystem_three_deep }
      it "should raise a not valid error" do
        expect { inspect_simple_ingest.call }.to raise_error(DulHydra::BatchError, /not a valid simple ingest/)
      end
    end
  end

end