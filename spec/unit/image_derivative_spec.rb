require 'spec_helper'

describe DulHydra::ImageDerivative do
  context ".thumbnail" do
    context "source is a file path" do
      context "image" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'library-devil.tiff') }
        context "using defaults" do
          it "should generate a thumbnail image" do
            thumbnail = DulHydra::ImageDerivative.thumbnail(master_file_path)
            thumbnail[:format].should eq("PNG")
            thumbnail[:width].should eq(79)
            thumbnail[:height].should eq(100)
          end
        end
      end
      context "pdf" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample.pdf') }
        context "using defaults" do
          it "should generate a thumbnail image" do
            thumbnail = DulHydra::ImageDerivative.thumbnail(master_file_path)
            thumbnail[:format].should eq("PNG")
            thumbnail[:width].should eq(77)
            thumbnail[:height].should eq(100)
          end
        end
      end
      context "neither an image nor a pdf" do
        let(:master_file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample.docx') }
        it "should raise a DulHydra::Error exception" do
          lambda { DulHydra::ImageDerivative.thumbnail(master_file_path) }.should raise_error(DulHydra::Error)
        end
      end
    end
  end
end
