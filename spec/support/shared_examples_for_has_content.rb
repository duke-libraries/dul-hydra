require 'spec_helper'
require 'openssl'

shared_examples "an object that can have content" do

  let(:object) { described_class.new(title: [ "I Have Content!" ]) }

  describe "when new content is saved" do
    context "and the content is a file" do
      let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
      before { object.content.content = file }
      it "should run a virus scan" do
        expect(VirusCheck).to receive(:execute).with(object, file).and_call_original
        object.save
      end
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
      context "and a virus is found" do
        before { allow(VirusCheck).to receive(:execute).with(object, file).and_raise(DulHydra::VirusFoundError) }
        it "should not persist the object" do
          expect { object.save }.to raise_error
          expect(object).to be_new_record
        end
      end
      context "and no virus is found" do
        before { object.save(validate: false) }
        it "should create a 'virus check' event for the object" do
          expect(VirusCheckEvent.for_object(object).count).to eq(1)
        end
      end
    end
    context "and the content is not a file" do
      before { object.content.content = "A string" }
      it "should not run a virus scan" do
        expect(VirusCheck).not_to receive(:execute)
        object.save!
      end
    end
  end

  describe "#upload" do
    it "should change the content" do
      expect { object.upload fixture_file_upload("library-devil.tiff", "image/tiff") }.to change { object.content.content }
    end
  end

  describe "#upload!" do 
    it "should change the content" do
      expect { object.upload! fixture_file_upload("library-devil.tiff", "image/tiff") }.to change { object.content.content }
    end    
    it "should persist the object" do
      expect { object.upload! fixture_file_upload("library-devil.tiff", "image/tiff") }.to change { object.pid } 
    end
  end

  context "#validate_checksum!" do
    let!(:checksum) { "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a" }
    let!(:checksum_type) { "SHA-256" }
    before { object.upload fixture_file_upload("library-devil.tiff", "image/tiff") }
    context "with unpersisted content" do
      before { allow(object).to receive(:content_changed?) { true } }
      it "should raise an exception" do
        expect { object.validate_checksum!(checksum, checksum_type) }.to raise_error DulHydra::Error
      end
    end
    context "with persisted content" do
      before do 
        object.save
        object.reload
      end
      context "and the checksum type is invalid" do
        it "should raise an exception" do
          expect { object.validate_checksum!("0123456789abcdef", "FOO-BAR") }.to raise_error ArgumentError
        end
      end
      context "and the checksum type is the same as the datastream checksum type" do
        it "should compare the provided checksum with the datastream checksum" do
          expect(object.content).to receive(:checksum).and_call_original
          expect { object.validate_checksum!(checksum, checksum_type) }.not_to raise_error DulHydra::ChecksumInvalid
        end
      end
      context "and the checksum type differs from the datastream checksum type" do 
        it "should generate a checksum for comparison" do
          expect(object.content).not_to receive(:checksum).and_call_original
          expect(object.content).to receive(:content).and_call_original
          expect(OpenSSL::Digest).to receive(:const_get).with(:MD5).and_call_original
          expect { object.validate_checksum!("273ae0f4aa60d94e89bc0e0652ae2c8f", "MD5") }.not_to raise_error DulHydra::ChecksumInvalid
        end
      end
      context "and the checksum doesn't match" do
        it "should raise an exception" do
          expect { object.validate_checksum!("0123456789abcdef", checksum_type) }.to raise_error DulHydra::ChecksumInvalid
        end
      end
    end
  end
end
