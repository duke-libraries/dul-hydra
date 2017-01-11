RSpec.describe FixityCheckJob do

  it_behaves_like "an abstract job"

  it "uses the :fixity queue" do
    expect(described_class.queue_name).to eq(:fixity)
  end

  describe ".perform" do
    let!(:obj) { double(fixity_check: nil) }
    before do
      allow(ActiveFedora::Base).to receive(:find).with("test:1") { obj }
    end
    it "should call `fixity_check` on the object" do
      expect(obj).to receive(:fixity_check)
      described_class.perform("test:1")
    end
  end

end
