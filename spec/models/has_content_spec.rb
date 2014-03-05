require 'spec_helper'

describe DulHydra::HasContent do
  let(:obj) { FactoryGirl.build(:test_content) }
  it "should have a content_type" do
    obj.content.stub(:mimeType).and_return("image/tiff")
    expect(obj.content_type).to eq("image/tiff")
  end
  context "should respond_to :image?" do
    it "when it's an image" do
      obj.stub(:content_type).and_return("image/png")
      expect(obj.image?).to be_true
    end
    it "when it's a non-image type" do
      obj.stub(:content_type).and_return("application/pdf")
      expect(obj.image?).to be_false
    end
    it "when content_type is nil" do
      obj.stub(:content_type).and_return(nil)
      expect(obj.image?).to be_false
    end
  end
  context "should respond_to :pdf?" do
    it "when it's an image" do
      obj.stub(:content_type).and_return("image/png")
      expect(obj.pdf?).to be_false
    end
    it "when it's a PDF" do
      obj.stub(:content_type).and_return("application/pdf")
      expect(obj.pdf?).to be_true
    end
    it "when content_type is nil" do
      obj.stub(:content_type).and_return(nil)
      expect(obj.pdf?).to be_false
    end
  end
end
