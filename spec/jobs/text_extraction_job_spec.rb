RSpec.describe TextExtractionJob do

  before {
    obj.upload! file
    described_class.perform(obj.id)
    obj.reload
  }

  describe "PDF file with text" do
    let(:obj) { Component.new }
    let(:file) { fixture_file_upload("sample.pdf") }
    specify {
      expect(obj.extractedText.content.strip)
        .to eq("This is a sample document.")
      event = obj.update_events.last
      expect(event).to be_success
      expect(event.summary).to eq("Text extraction")
      expect(event.software).to match(/Apache Tika/)
    }
  end

  describe "File with no text content" do
    let(:obj) { Target.new }
    let(:file) { fixture_file_upload("target.png") }
    specify {
      expect(obj.extractedText).not_to have_content
      event = obj.update_events.last
      expect(event).to be_failure
      expect(event.summary).to eq("Text extraction")
      expect(event.detail).to eq("Unable to extract text or file contains no text.")

      expect(event.software).to match(/Apache Tika/)
    }
  end

  describe "File with password" do
    let(:obj) { Component.new }
    let(:file) { fixture_file_upload("password-protected.docx") }
    specify {
      expect(obj.extractedText).not_to have_content
      event = obj.update_events.last
      expect(event).to be_failure
      expect(event.summary).to eq("Text extraction")
      expect(event.detail).to eq("Unable to extract text from encrypted document.")

      expect(event.software).to match(/Apache Tika/)
    }
  end

end
