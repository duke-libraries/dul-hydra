require 'spec_helper'
require 'support/ingest_folder_helper'

RSpec.describe InspectStandardIngest, type: :service, batch: true, standard_ingest: true do

  let(:filepath) { "/foo/bar" }
  let(:datapath) { File.join(filepath, 'data') }
  let(:inspect_standard_ingest) { InspectStandardIngest.new(filepath, standard_ingest_configuration[:scanner]) }
  let(:filesystem) { Filesystem.new }
  let(:scan_results) { ScanFilesystem::Results.new(filesystem, []) }

  before do
    allow(Dir).to receive(:exist?) { true }
    allow(File).to receive(:readable?).with(datapath) { true }
    allow_any_instance_of(ScanFilesystem).to receive(:call) { scan_results }
    filesystem.tree = filesystem_standard_ingest
  end

  describe "standard ingest folder" do
    describe "filepath" do
      context 'valid filepath' do
        it "should not raise an error" do
          expect { inspect_standard_ingest.call }.to_not raise_error
        end
      end
      context "filepath does not point to an existing directory" do
        before { allow(Dir).to receive(:exist?) { false } }
        it "should raise a not found or not directory error" do
          expect { inspect_standard_ingest.call }.to raise_error(DulHydra::BatchError, /not found or is not a directory/)
        end
      end
      context "filepath is not readable" do
        before do
          allow(File).to receive(:readable?).with(datapath) { false }
        end
        it "should raise a not readable error" do
          expect { inspect_standard_ingest.call }.to raise_error(DulHydra::BatchError, /not readable/)
        end
      end
    end
  end

  describe "filesystem" do
    context "valid for standard ingest" do
      it "should report the number of files" do
        expect(inspect_standard_ingest.call.file_count).to eq(8)
      end
      it "should report the excluded files/folders" do
        expect(inspect_standard_ingest.call.exclusions).to eq([])
      end
      it "should report the content model stats" do
        stats = inspect_standard_ingest.call.content_model_stats
        expect(stats).to include(collections: 1)
        expect(stats).to include(items: 4)
        expect(stats).to include(components: 6)
        expect(stats).to include(targets: 1)
      end
      it "should report the filesystem object" do
        expect(inspect_standard_ingest.call.filesystem).to be_a(Filesystem)
      end
    end
    context "too deep for standard ingest" do
      before { filesystem.tree = filesystem_three_deep }
      it "should raise a not valid error" do
        expect { inspect_standard_ingest.call }.to raise_error(DulHydra::BatchError, /not a valid standard ingest/)
      end
    end
  end

end
