RSpec.describe FixityCheckJob, fixity: true do
  specify {
    expect(described_class.queue).to eq(:fixity)
  }

  describe ".perform" do
    let!(:obj) { double(fixity_check: nil) }
    before do
      allow(ActiveFedora::Base).to receive(:find).with("test-1") { obj }
    end
    specify {
      expect(obj).to receive(:check_fixity)
      described_class.perform("test-1")
    }
  end
end
