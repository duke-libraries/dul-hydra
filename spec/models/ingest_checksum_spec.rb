require 'spec_helper'

RSpec.describe IngestChecksum, type: :model, batch: true, ingest: true do

  let(:checksum_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums.txt') }
  let(:ic) { IngestChecksum.new(checksum_filepath) }

  describe "checksum" do
    it "should provide the recorded checksum" do
      expect(ic.checksum('/base/path/subpath/file01002.tif')).
          to eq('ea14084df3e55b170e7063d6ac705b33423921fc69e4edcbc843743b6651b1cb')
      expect(ic.checksum('/base/path/subpath/image001.tif')).to be nil
    end
  end

end
