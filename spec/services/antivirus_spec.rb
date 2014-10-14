require 'spec_helper'

describe Ddr::Services::Antivirus, antivirus: true do
  let(:file) { fixture_file_upload "library-devil.tiff" }
  it "should reload the db" do
    expect(described_class).to receive(:reload!)
    described_class.scan file
  end
  it "should report whether a file is infected" do
    expect(described_class.scan(file)).not_to have_virus
  end
  it "should report whether there was an error" do
    expect(described_class.scan(file)).not_to be_error
  end
  context "when a virus is found" do
    before do
      allow(Ddr::Services::Antivirus).to receive(:scan_one).with(file.path) do
        Ddr::Services::Antivirus::ScanResult.new "Deadly Virus!", file.path
      end
    end
    it "should raise an execption" do
      expect { described_class.scan(file) }.to raise_error(Ddr::Models::VirusFoundError)
    end
  end
  context "when an error occurs in the engine" do
    before do
      allow(Ddr::Services::Antivirus).to receive(:scan_one).with(file.path) do
        Ddr::Services::Antivirus::ScanResult.new 1, file.path
      end
    end
    it "should raise an execption" do
      expect { described_class.scan(file) }.to raise_error(Ddr::Models::Error)
    end
  end
end
