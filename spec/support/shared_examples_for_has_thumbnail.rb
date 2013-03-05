require 'spec_helper'
#require 'RMagick'

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
    let(:thumbnail_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil-thumbnail.jpg') }
    before do
      object.content.content_file = File.new(master_file_path, "rb")
      object.save!
    end
    context "#generate_thumbnail" do
      let(:thumbnail) { object.generate_thumbnail }
      context "source datastream is an image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
        context "using defaults" do
          let(:expected_thumbnail) { MiniMagick::Image.open(thumbnail_file_path) }
          it "should generate a thumbnail image" do
            thumbnail[:size].should eq(expected_thumbnail[:size])
            thumbnail[:format].should eq(expected_thumbnail[:format])
#            Magick::Image.from_blob(thumbnail.to_blob).first.should eq(expected_thumbnail)
          end
        end
      end
      context "source datastream is not an image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample.pdf') }
        it "should not generate a thumbnail image" do
          thumbnail.should be_nil
        end
      end
    end
    context "#generate_thumbnail!" do
      let(:expected_thumbnail) { File.open(thumbnail_file_path, 'rb') { |f| f.read } }
      before do
        object.generate_thumbnail!
      end
      context "source datastream is an image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
        context "using defaults" do
          it "should generate a thumbnail image" do
            object.thumbnail.content.should eq(expected_thumbnail)
          end
        end
      end
      context "source datastream is not an image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample.pdf') }
        it "should not generate a thumbnail image" do
          object.thumbnail.content.should be_nil
        end
      end
    end
  end
  
end
