require 'spec_helper'

RSpec.describe ScanFilesystem, type: :service, batch: true, standard_ingest: true do

  let(:filepath) { '/test/directory' }

  before do
    allow(Dir).to receive(:foreach).with(filepath).and_return(
      Enumerator.new { |y| y << "." << ".." << "Thumbs.db" << "movie.mp4" << "file01001.tif" << "images" << "itemA" << "itemB" }
    )
    allow(Dir).to receive(:foreach).with(File.join(filepath, 'images')).and_return(
      Enumerator.new { |y| y << "." << ".." }
    )
    allow(Dir).to receive(:foreach).with(File.join(filepath, 'itemA')).and_return(
      Enumerator.new { |y| y << "." << ".." << "file01.pdf" << "track01.wav" }
    )
    allow(Dir).to receive(:foreach).with(File.join(filepath, 'itemB')).and_return(
    Enumerator.new { |y| y << "." << ".." << "file02.pdf" << "track02.wav" }
    )
    allow(File).to receive(:directory?).and_return(false)
    allow(File).to receive(:directory?).with(File.join(filepath, 'images')).and_return(true)
    allow(File).to receive(:directory?).with(File.join(filepath, 'itemA')).and_return(true)
    allow(File).to receive(:directory?).with(File.join(filepath, 'itemB')).and_return(true)
  end

  describe "scan" do
    describe "exclude" do
      let(:scanner) { described_class.new(filepath, { exclude: [ 'Thumbs.db' ] }) }
      let(:expected_filesystem) { Filesystem.new.tree = sample_filesystem }
      let(:expected_exclusions) { [ File.join(filepath, 'Thumbs.db'), File.join(filepath, 'images') ] }
      it "should return the expected results" do
        results = scanner.call
        expect(results.filesystem.marshal_dump).to eq(expected_filesystem.marshal_dump)
        expect(results.exclusions).to match_array(expected_exclusions)
      end
    end
    describe "include" do
      let(:scanner) { described_class.new(filepath, { include: [ '.mp4', '.pdf', '.tif', '.wav' ] }) }
      let(:expected_filesystem) { Filesystem.new.tree = sample_filesystem }
      let(:expected_exclusions) { [ File.join(filepath, 'Thumbs.db'), File.join(filepath, 'images') ] }
      it "should return the expected results" do
        results = scanner.call
        expect(results.filesystem.marshal_dump).to eq(expected_filesystem.marshal_dump)
        expect(results.exclusions).to match_array(expected_exclusions)
      end
    end
  end

end
