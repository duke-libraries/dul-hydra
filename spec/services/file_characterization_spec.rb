RSpec.describe FileCharacterization do

  subject { described_class.new(obj) }

  before {
    obj.content.checksumType = "SHA-1"
    obj.save!
  }

  let(:obj) { FactoryGirl.create(:component) }
  let(:fits_output) { fixture_file_upload('fits.xml') }
  let(:fits_xml) { fits_output.read }

  describe "when there is an error running FITS" do
    before {
      allow(subject).to receive(:run_fits).and_raise(FileCharacterization::FITSError)
    }
    it "does not add content to the `fits` datastream" do
      begin
        subject.call
      rescue FileCharacterization::FITSError
      ensure
        expect(subject.fits).not_to have_content
      end
    end
  end

  describe "when FITS runs successfully" do
    before {
      allow(subject).to receive(:run_fits) { fits_xml }
    }
    it "persists the FITS XML output to the `fits` datastream" do
      subject.call
      expect(subject.fits.content).to be_equivalent_to(fits_xml)
    end
  end

end
