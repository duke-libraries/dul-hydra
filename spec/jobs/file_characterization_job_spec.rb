RSpec.describe FileCharacterizationJob, jobs: true, file_characterization: true do

  let(:obj) { double }

  before { allow(ActiveFedora::Base).to receive(:find).with("test:1") { obj } }

  specify {
    expect(FileCharacterization).to receive(:call).with(obj) { nil }
    described_class.perform("test:1")
  }

end
