require 'spec_helper'

shared_examples "an object that has a thumbnail" do
  let!(:object) { described_class.create! }
  after { object.delete }
  context "before thumbnail generation" do
    it "should not have a thumbnail" do
      object.has_thumbnail?.should be_false
    end
  end
  context "generate thumbnail" do
    before do
      object.content.content_file = File.new(master_file_path, "rb")
      object.save!
    end
    context "#generate_thumbnail" do
      let(:thumbnail) { object.generate_thumbnail }
      context "source datastream is an image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
        context "using defaults" do
          it "should generate a thumbnail image" do
            thumbnail[:format].should eq("PNG")
            thumbnail[:width].should eq(79)
            thumbnail[:height].should eq(100)
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
            object.thumbnail.content.should_not be_nil
            object.thumbnail.mimeType.should eq("image/png")
            object.has_thumbnail?.should be_true
          end
        end
      end
      context "source datastream is not an image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample.pdf') }
        it "should not generate a thumbnail image" do
          object.thumbnail.content.should be_nil
          object.has_thumbnail?.should be_false
        end
      end
    end
  end
  
end
