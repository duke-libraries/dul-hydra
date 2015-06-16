require 'spec_helper'

RSpec.describe SimpleIngestChecksum, type: :model, batch: true, simple_ingest: true do

  let(:checksum_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'simple_ingest', 'manifest-sha256.txt') }
  let(:sic) { SimpleIngestChecksum.new(checksum_filepath) }

  describe "checksum" do
    it "should provide the recorded checksum" do
      expect(sic.checksum('file01001.tif')).to eq('120ad0814f207c45d968b05f7435034ecfee8ac1a0958cd984a070dad31f66f3')
      expect(sic.checksum('targets/T001.tiff')).to eq('6890139bcc7b9cc0341fee77e8149aad4c7368eb5d0511ae480609dabd48b0c5')
      expect(sic.checksum('image001.tif')).to be nil
    end
  end

end