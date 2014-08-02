require 'spec_helper'
require 'openssl'

shared_examples "an object that can have content" do

  let(:object) { described_class.new(title: [ "I Have Content!" ]) }

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
      expect(object).to receive(:virus_scan).with(file)
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

  context "#validate_checksum!" do
    let!(:checksum) { "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a" }
    let!(:checksum_type) { "SHA-256" }
    before { object.upload fixture_file_upload("library-devil.tiff", "image/tiff") }
    context "with unpersisted content" do
      it "should raise an exception" do
        expect { object.validate_checksum!(checksum, checksum_type) }.to raise_error
      end
    end
    context "with persisted content" do
      before do 
        object.save
        object.reload
      end
      context "and the checksum type is invalid" do
        it "should raise an exception" do
          expect { object.validate_checksum!("0123456789abcdef", "FOO-BAR") }.to raise_error
        end
      end
      context "and the checksum type is the same as the datastream checksum type" do
        it "should compare the provided checksum with the datastream checksum" do
          expect(object.content).to receive(:checksum).and_call_original
          expect { object.validate_checksum!(checksum, checksum_type) }.not_to raise_error
        end
      end
      context "and the checksum type differs from the datastream checksum type" do 
        it "should generate a checksum for comparison" do
          expect(object.content).not_to receive(:checksum).and_call_original
          expect(object.content).to receive(:content).and_call_original
          expect(OpenSSL::Digest).to receive(:const_get).with(:MD5).and_call_original
          expect { object.validate_checksum!("273ae0f4aa60d94e89bc0e0652ae2c8f", "MD5") }.not_to raise_error
        end
      end
      context "and the checksum doesn't match" do
        it "should raise an exception" do
          expect { object.validate_checksum!("0123456789abcdef", checksum_type) }.to raise_error
        end
      end
    end
  end

  describe "deleting" do
    before { object.upload! fixture_file_upload("library-devil.tiff", "image/tiff") }
    it "should delete the content file" do
      path = object.external_datastream_file_path(object.content)
      expect(File.exists?(path)).to be true
      object.destroy
      expect(File.exists?(path)).to be false
    end
  end

end
