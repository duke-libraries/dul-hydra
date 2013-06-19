require 'spec_helper'
require 'tempfile'

shared_examples "an object that has content" do
  let!(:object) { described_class.create! }
  after { object.delete }
  context "object does have content" do
    let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
    before do
      object.content.content = File.new(file_path, "rb")
      object.save!
    end
    context "defaults" do
      it "should have a default file prefix, file extension, and file name" do
        pid_prefix = object.pid.sub(':', '_')
        object.content.default_file_prefix.should == "#{pid_prefix}_content"
        object.content.default_file_extension.should == "tiff"
        object.content.default_file_name.should == "#{pid_prefix}_content.tiff"
      end
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
    context "#has_content?" do
      it "should return true" do
        object.has_content?.should be_true
      end
    end
  end
  context "object does not have content" do
    context "#has_content?" do
      it "should return false" do
        object.has_content?.should be_false
      end
    end
  end
end
