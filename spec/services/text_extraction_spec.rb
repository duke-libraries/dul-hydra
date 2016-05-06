RSpec.describe TextExtraction do
  before { obj.upload! file }

  describe "PDF file with text" do
    let(:obj) { Component.new }
    let(:file) { fixture_file_upload("sample.pdf") }
    specify {
      text = described_class.call(obj.content)
      expect(text.strip).to eq("This is a sample document.")
    }
  end

  describe "File with no text content" do
    let(:obj) { Target.new }
    let(:file) { fixture_file_upload("target.png") }
    specify {
      expect { described_class.call(obj.content) }
        .to raise_error(described_class::NoTextError)
    }
  end

  describe "File with password" do
    let(:obj) { Component.new }
    let(:file) { fixture_file_upload("password-protected.docx") }
    specify {
      expect { described_class.call(obj.content) }
        .to raise_error(described_class::EncryptedDocumentError)
    }
  end

  describe "Other error" do
    let(:obj) { Component.new }
    let(:file) { fixture_file_upload("sample.pdf") }
    before {
      allow_any_instance_of(Process::Status).to receive(:success?) { false }
    }
    specify {
      expect { described_class.call(obj.content) }
        .to raise_error(described_class::CommandError)
    }
  end
end
