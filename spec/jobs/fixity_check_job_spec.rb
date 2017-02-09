RSpec.describe FixityCheckJob do

  it_behaves_like "an abstract job"

  it "uses the :fixity queue" do
    expect(described_class.queue_name).to eq(:fixity)
  end

  describe ".perform" do
    let(:obj) { FactoryGirl.create(:item) }
    specify {
      allow(ActiveFedora::Base).to receive(:find).with(obj.id) { obj }
      expect(FixityCheck).to receive(:call).with(obj).and_call_original
      described_class.perform(obj.id)
    }
  end

end
