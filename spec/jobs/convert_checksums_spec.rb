module DulHydra::Jobs
  RSpec.describe ConvertChecksums do

    let(:obj) { FactoryGirl.create(:collection) }

    before {
      obj.datastreams.each do |dsid, ds|
        next unless ds.has_content?
        ds.checksumType = "SHA-256"
      end
      obj.save!
    }

    describe "when checksum validation fails on a datastream" do
      before do
        allow_any_instance_of(ActiveFedora::Datastream).to receive(:dsChecksumValid) { false }
      end
      it "raises an exception" do
        expect { described_class.perform(obj.pid) }.to raise_error(Ddr::Models::ChecksumInvalid)
      end
    end

    describe "when checksum validation passes on all datastreams" do
      it "converts the checksums to SHA-1" do
        described_class.perform(obj.pid)
        obj.reload
        expect(obj.datastreams["DC"].checksumType).to eq "SHA-1"
        expect(obj.datastreams["RELS-EXT"].checksumType).to eq "SHA-1"
        expect(obj.datastreams["descMetadata"].checksumType).to eq "SHA-1"
      end
    end

  end
end
