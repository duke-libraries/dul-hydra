RSpec.describe TextExtractionJob do

  let(:obj) { Component.new }
  let(:file) { fixture_file_upload("sample.pdf") }

  before { obj.upload! file }

  specify {
    Resque.enqueue(described_class, obj.id)
    obj.reload
    expect(obj.extractedText.content.strip)
      .to eq("This is a sample document.")
    event = obj.update_events.last
    expect(event.summary).to eq("Text extracted from content file")
    expect(event.software).to match(/Apache Tika/)
  }

end
