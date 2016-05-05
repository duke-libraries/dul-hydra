RSpec.describe TextExtraction do
  let(:obj) { Component.new }
  let(:file) { fixture_file_upload("sample.pdf") }

  before { obj.upload! file }

  specify {
    text = described_class.call(obj.content)
    expect(text.strip).to eq("This is a sample document.")
  }
end
