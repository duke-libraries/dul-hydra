require 'spec_helper'
require 'RMagick'

shared_examples "an object that has a thumbnail" do
  let!(:object) { described_class.create! }
  after { object.delete }
  context "thumbnail datastream" do
    let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil-thumbnail.jpg') }
    before do
      object.thumbnail.content_file = File.new(file_path, "rb")
      object.save!
    end
    context "#content_file=" do
      it "should store the file content" do
        object.thumbnail.content.size.should == File.size(file_path)
      end
    end
  end
  context "generate thumbnail" do
    let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
    let(:thumbnail_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil-thumbnail.jpg') }
    before do
      object.content.content_file = File.new(master_file_path, "rb")
      object.save!
    end
    context "#generate_thumbnail" do
      let(:thumbnail) { object.generate_thumbnail }
      let(:expected_thumbnail) { Magick::Image.read(thumbnail_file_path).first }
      context "using defaults" do
        it "should generate a thumbnail image" do
          Magick::Image.from_blob(thumbnail.to_blob).first.should == expected_thumbnail
        end
      end
    end
    context "#generate_thumbnail!" do
      let(:expected_thumbnail) { Magick::Image.read(thumbnail_file_path).first }
      before do
        object.generate_thumbnail!
      end
      context "using defaults" do
        it "should generate a thumbnail image" do
          Magick::Image.from_blob(object.thumbnail.content).first.should == expected_thumbnail
        end
      end
    end
  end
  
end
