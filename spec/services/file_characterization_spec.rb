RSpec.describe FileCharacterization do

  subject { described_class.new(obj) }

  before {
    obj.content.checksumType = "SHA-1"
    obj.save!
  }

  let(:obj) { FactoryGirl.create(:component) }
  let(:fits_output) { "<fits/>" }

  describe "when there is an error running FITS" do
    before {
      allow(subject).to receive(:run_fits).and_raise(FileCharacterization::FITSError)
    }
    specify {
      begin
        subject.call
      rescue FileCharacterization::FITSError
      ensure
        expect(subject.fits).not_to have_content
      end
    }
  end

  describe "when FITS runs successfully" do
    before {
      allow(subject).to receive(:run_fits) { fits_output }
    }
    specify {
      subject.call
      expect(subject.fits.content).to eq(fits_output)
    }
  end

end
