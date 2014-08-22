require 'spec_helper'
require 'openssl'

shared_examples "an object that can have content" do

  let(:object) { described_class.new(title: [ "I Have Content!" ]) }

  it "should delegate :validate_checksum! to :content" do
    checksum = "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a"
    expect(object.content).to receive(:validate_checksum!).with(checksum, "SHA-256")
    object.validate_checksum!(checksum, "SHA-256")
  end

  describe "when new content is saved" do
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    before { object.upload file }
    it "should have an original_filename" do
      object.save
      expect(object.original_filename).to eq("library-devil.tiff")
    end
    it "should have a content_type" do
      object.save
      expect(object.content_type).to eq("image/tiff")
    end
    it "should have a thumbnail (if it's an appropriate type)" do
      object.save
      expect(object.thumbnail).to be_present
    end
    it "should create a 'virus check' event for the object" do
      expect { object.save }.to change { object.virus_checks.count }.by(1)
    end
  end

  describe "#upload" do
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    it "should change the content location" do
      expect { object.upload file }.to change { object.content.dsLocation }
    end
    it "should check the file for viruses" do
      expect(DulHydra::Services::Antivirus).to receive(:scan).with(file)
      object.upload file
    end
  end

  describe "#upload!" do 
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    it "should change the content" do
      expect { object.upload! file }.to change { object.content.content }
    end    
    it "should persist the object" do
      expect { object.upload! file }.to change { object.pid } 
    end
  end

  describe "deleting" do
    before { object.upload! fixture_file_upload("library-devil.tiff", "image/tiff") }
    it "should delete the content file" do
      path = object.content.file_path
      expect(File.exists?(path)).to be true
      object.destroy
      expect(File.exists?(path)).to be false
    end
  end

end
