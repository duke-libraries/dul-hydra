require 'spec_helper'

module ActiveFedora
  describe Datastream do

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

    end # external datastreams

  end
end
