require 'spec_helper'

RSpec.describe StandardIngestChecksum, type: :model, batch: true, standard_ingest: true do

  let(:checksum_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'standard_ingest', 'manifest-sha1.txt') }
  let(:sic) { StandardIngestChecksum.new(checksum_filepath) }

  describe "checksum" do
    it "should provide the recorded checksum" do
      expect(sic.checksum('file01001.tif')).to eq('7cc5abd7ed8c1c907d86bba5e6e18ed6c6ec995c')
      expect(sic.checksum('targets/T001.tiff')).to eq('2cf23f0035c12b6242093e93d0f7eeba0b1e08e8')
      expect(sic.checksum('image001.tif')).to be nil
    end
  end

end
