require 'spec_helper'
require 'tempfile'

shared_examples "an object that has content" do
  let(:object) do
    obj = described_class.new(title: "I Have Content!")
    obj.save(validate: false)
    obj
  end
  after { ActiveFedora::Base.destroy_all }
  context "which is uploaded" do
    before do
      object.upload fixture_file_upload("library-devil.tiff", "image/tiff")
      object.save(validate: false)
    end
    it "should have content" do
      expect(object).to have_content
    end
    it "should have an original_filename" do
      expect(object.original_filename).to eq("library-devil.tiff")
    end
    it "should have a content_type" do
      expect(object.content_type).to eq("image/tiff")
    end
    it "should have a thumbnail (if it's an appropriate type)" do
      expect(object.thumbnail).to be_present
    end
    it "should have a default file prefix, file extension, and file name" do
      # XXX Does this belong in a test module for FileContentDatastream?
      pid_prefix = object.pid.sub(':', '_')
      object.content.default_file_prefix.should == "#{pid_prefix}_content"
      object.content.default_file_extension.should == "tiff"
      object.content.default_file_name.should == "#{pid_prefix}_content.tiff"
    end
    context "#write_content" do
      let(:tmpfile) { Tempfile.new('content', :encoding => 'ascii-8bit') }
      after { tmpfile.unlink }
      it "should write the content to a file" do
        tmppath = tmpfile.path
        object.content.write_content(tmpfile)
        tmpfile.close
        object.content.content.size.should == File.size(tmppath)
      end
    end
  end
  context "object has not uploaded content" do
    it "should not have content" do
      expect(object).not_to have_content
    end
  end
end
