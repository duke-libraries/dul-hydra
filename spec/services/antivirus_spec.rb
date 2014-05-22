require 'spec_helper'

def installed?
  DulHydra::Services::Antivirus.installed?
end

describe DulHydra::Services::Antivirus, if: installed? do
  let(:file) { fixture_file_upload "library-devil.tiff" }
  it "should report whether a file is infected" do
    expect(described_class.scan(file)).not_to have_virus
  end
  it "should report whether there was an error" do
    expect(described_class.scan(file)).not_to be_error
  end
  context "when a virus is found" do
    before do
      allow(DulHydra::Services::Antivirus).to receive(:scan_one).with(file) do
        DulHydra::Services::Antivirus::ScanResult.new "Deadly Virus!", file.path
      end
    end
    it "should raise an execption" do
      expect { described_class.scan(file) }.to raise_error(DulHydra::Services::Antivirus::VirusFoundError)
    end
  end
  context "when an error occurs in the engine" do
    before do
      allow(DulHydra::Services::Antivirus).to receive(:scan_one).with(file) do
        DulHydra::Services::Antivirus::ScanResult.new 1, file.path
      end
    end
    it "should raise an execption" do
      expect { described_class.scan(file) }.to raise_error(DulHydra::Services::Antivirus::AntivirusEngineError)
    end
  end
end
