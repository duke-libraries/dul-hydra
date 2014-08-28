require 'spec_helper'

module ActiveFedora
  describe Datastream do

    describe "#validate_checksum!" do
      subject { described_class.new(nil, nil, controlGroup: "M") }
      let!(:checksum) { "dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a" }
      let!(:checksum_type) { "SHA-256" }
      context "with unpersisted content" do
        context "the datstream is new" do
          before { allow(subject).to receive(:new?) { true } }
          it "should raise an exception" do
            expect { subject.validate_checksum!(checksum, checksum_type) }.to raise_error
          end
        end
        context "the datastream content has changed" do
          before { allow(subject).to receive(:content_changed?) { true } }
          it "should raise an exception" do
            expect { subject.validate_checksum!(checksum, checksum_type) }.to raise_error
          end
        end
      end
      context "with persisted content" do
        before do
          allow(subject).to receive(:new?) { false }
          allow(subject).to receive(:pid) { "foobar:1" }
          allow(subject).to receive(:dsCreateDate) { DateTime.now }
          allow(subject).to receive(:checksum) { checksum }
          allow(subject).to receive(:checksumType) { checksum_type }
        end
        context "and the repository internal checksum in invalid" do
          before { allow(subject).to receive(:dsChecksumValid) { false } }
          it "should raise an error" do
            expect { subject.validate_checksum!(checksum, checksum_type) }.to raise_error
          end
        end
        context "and the repository internal checksum is valid" do
          before { allow(subject).to receive(:dsChecksumValid) { true } }
          context "and the checksum type is invalid" do
            it "should raise an exception" do
              expect { subject.validate_checksum!("0123456789abcdef", "FOO-BAR") }.to raise_error
            end
          end
          context "and the checksum type is nil" do
            it "should compare the provided checksum with the datastream checksum" do
              expect { subject.validate_checksum!(checksum) }.not_to raise_error
            end
          end
          context "and the checksum type is the same as the datastream checksum type" do
            it "should compare the provided checksum with the datastream checksum" do
              expect { subject.validate_checksum!(checksum, checksum_type) }.not_to raise_error
            end
          end
          context "and the checksum type differs from the datastream checksum type" do 
            let!(:md5digest) { "273ae0f4aa60d94e89bc0e0652ae2c8f" }
            it "should generate a checksum for comparison" do
              expect(subject).not_to receive(:checksum)
              allow(subject).to receive(:content_digest).with("MD5") { md5digest }
              expect { subject.validate_checksum!(md5digest, "MD5") }.not_to raise_error
            end
          end
          context "and the checksum doesn't match" do
            it "should raise an exception" do
              expect { subject.validate_checksum!("0123456789abcdef", checksum_type) }.to raise_error
            end
          end
        end
      end
    end

    describe "extensions for external datastreams" do
      subject { described_class.new(nil, nil, controlGroup: "E") }

      describe "#file_path" do
        it "should return nil when dsLocation is not set" do
          expect(subject.file_path).to be_nil
        end
        it "should return nil when dsLocation is not a file URI" do
          subject.dsLocation = "http://library.duke.edu/"
          expect(subject.file_path).to be_nil
        end
        it "should return the file path when dsLocation is a file URI" do
          subject.dsLocation = "file:/tmp/foo/bar.txt"
          expect(subject.file_path).to eq "/tmp/foo/bar.txt"
        end
      end

      describe "#file_name" do
        it "should return nil when dsLocation is not set" do
          expect(subject.file_name).to be_nil
        end
        it "should return nil when dsLocation is not a file URI" do
          subject.dsLocation = "http://library.duke.edu/"
          expect(subject.file_name).to be_nil
        end
        it "should return the file name when dsLocation is a file URI" do
          subject.dsLocation = "file:/tmp/foo/bar.txt"
          expect(subject.file_name).to eq "bar.txt"
        end
      end

      describe "#file_size" do
        it "should return nil when dsLocation is not set" do
          expect(subject.file_size).to be_nil
        end
        it "should return nil when dsLocation is not a file URI" do
          subject.dsLocation = "http://library.duke.edu/"
          expect(subject.file_size).to be_nil
        end
        it "should return the file name when dsLocation is a file URI" do
          allow(File).to receive(:size).with("/tmp/foo/bar.txt") { 42 }
          subject.dsLocation = "file:/tmp/foo/bar.txt"
          expect(subject.file_size).to eq 42
        end        
      end

    end # external datastreams

  end
end
