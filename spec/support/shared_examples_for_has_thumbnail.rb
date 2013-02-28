require 'spec_helper'
require 'tempfile'

shared_examples "an object that has a thumbnail" do
  let!(:object) { described_class.create! }
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
  before do
    object.thumbnail.content_file = File.new(file_path, "rb")
    object.save!
  end
  after { object.delete }
  context "thumbnail datastream" do
    context "#content_file=" do
      it "should store the file content" do
        object.thumbnail.content.size.should == File.size(file_path)
      end
    end
  end
end
