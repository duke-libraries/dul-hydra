RSpec.describe FileCharacterizationJob do

  let(:obj) { double }

  before { allow(ActiveFedora::Base).to receive(:find).with("test:1") { obj } }

  it_behaves_like "an abstract job"

  specify {
    expect(FileCharacterization).to receive(:call).with(obj) { nil }
    described_class.perform("test:1")
  }

end
