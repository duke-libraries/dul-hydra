RSpec.describe UpdateIndexJob do

  it "should use the :index queue" do
    expect(described_class.queue).to eq(:index)
  end

  describe ".perform" do
    let!(:obj) { double(update_index: nil) }
    before do
      allow(ActiveFedora::Base).to receive(:find).with("test:1") { obj }
    end
    it "should call `update_index` on the object" do
      expect(obj).to receive(:update_index)
      described_class.perform("test:1")
    end
  end

end
