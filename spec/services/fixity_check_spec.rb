RSpec.describe FixityCheck do

  before(:all) do
    class TestFixityCheck < Ddr::Models::Base
      include Ddr::Models::HasContent
      include Ddr::Models::Describable
      has_file_datastream name: "e_content", control_group: "E"
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestFixityCheck)
  end

  before(:each) do
    file = fixture_file_upload('sample.pdf')
    obj.descMetadata.title = [ "Title" ]
    obj.e_content.dsLocation = Ddr::Utils.path_to_uri(file.path)
    obj.save!
  end

  let(:obj) { TestFixityCheck.new }

  specify {
    event = described_class.call(obj)
    expect(event).to be_a(Ddr::Events::FixityCheckEvent)
    expect(event.pid).to eq(obj.id)
    expect(event).to be_success
    expect(event.detail).to match /^e_content: true$/
    expect(event.detail).to match /^descMetadata: true$/
  }

  specify {
    allow(obj.descMetadata).to receive(:dsChecksumValid) { false }
    event = described_class.call(obj)
    expect(event).to be_failure
    expect(event.detail).to match /^e_content: true$/
    expect(event.detail).to match /^descMetadata: false$/
  }

  specify {
    allow(FileDigest).to receive(:sha1).with(obj.e_content.dsLocation) { "a6ae0d815c1a2aef551b45fe34a35ceea1828a4e" }
    event = described_class.call(obj)
    expect(event).to be_failure
    expect(event.detail).to match /^e_content: false$/
    expect(event.detail).to match /^descMetadata: true$/
  }

  specify {
    FileDigest.delete_all
    expect { described_class.call(obj) }.to raise_error(ActiveRecord::RecordNotFound)
  }

end
